{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.thermal-monitor;

  # Script to send notifications to desktop user
  notifyScript = pkgs.writeShellScript "thermal-notify" ''
    URGENCY="$1"
    TITLE="$2"
    MESSAGE="$3"

    # Find active user session
    USER=$(${pkgs.coreutils}/bin/who | ${pkgs.gnugrep}/bin/grep -E '\(:[0-9]+\)' | ${pkgs.coreutils}/bin/head -1 | ${pkgs.gawk}/bin/awk '{print $1}')

    if [ -n "$USER" ]; then
      # Get user's UID
      USER_ID=$(${pkgs.coreutils}/bin/id -u "$USER" 2>/dev/null)

      if [ -n "$USER_ID" ]; then
        # Send notification via user's dbus session
        ${pkgs.sudo}/bin/sudo -u "$USER" \
          DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
          ${pkgs.libnotify}/bin/notify-send \
          --urgency="$URGENCY" \
          --icon=dialog-warning \
          "$TITLE" "$MESSAGE"
      fi
    fi
  '';

  # Main monitoring script
  monitorScript = pkgs.writeShellScript "thermal-monitor" ''
    set -euo pipefail

    # Configuration
    CHECK_INTERVAL=${toString cfg.checkInterval}
    GPU_WARNING=${toString cfg.gpuWarningTemp}
    GPU_CRITICAL=${toString cfg.gpuCriticalTemp}
    GPU_EMERGENCY=${toString cfg.gpuEmergencyTemp}
    CPU_WARNING=${toString cfg.cpuWarningTemp}
    CPU_CRITICAL=${toString cfg.cpuCriticalTemp}
    CPU_EMERGENCY=${toString cfg.cpuEmergencyTemp}

    # State
    EMERGENCY_COUNT=0
    EMERGENCY_THRESHOLD=3
    LOG_DIR="/var/log/thermal-monitor"
    METRICS_LOG="$LOG_DIR/metrics.log"

    # Ensure log directory exists
    ${pkgs.coreutils}/bin/mkdir -p "$LOG_DIR"

    # Helper: check if desktop session is available
    has_desktop() {
      ${pkgs.coreutils}/bin/who | ${pkgs.gnugrep}/bin/grep -qE '\(:[0-9]+\)'
    }

    # Helper: send notification (only if desktop available)
    notify() {
      local urgency="$1"
      local title="$2"
      local message="$3"

      if has_desktop; then
        ${notifyScript} "$urgency" "$title" "$message" || true
      fi
    }

    # Helper: get GPU temperatures (comma-separated)
    get_gpu_temps() {
      ${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi \
        --query-gpu=temperature.gpu \
        --format=csv,noheader,nounits 2>/dev/null | ${pkgs.coreutils}/bin/tr '\n' ',' | ${pkgs.gnused}/bin/sed 's/,$//'
    }

    # Helper: get GPU power draw (comma-separated)
    get_gpu_powers() {
      ${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi \
        --query-gpu=power.draw \
        --format=csv,noheader,nounits 2>/dev/null | ${pkgs.coreutils}/bin/tr '\n' ',' | ${pkgs.gnused}/bin/sed 's/,$//'
    }

    # Helper: get CPU temperature (max of all cores)
    get_cpu_temp() {
      ${pkgs.lm_sensors}/bin/sensors -u 2>/dev/null | \
        ${pkgs.gnugrep}/bin/grep -E 'temp[0-9]+_input' | \
        ${pkgs.gawk}/bin/awk -F: '{print $2}' | \
        ${pkgs.coreutils}/bin/sort -rn | ${pkgs.coreutils}/bin/head -1 | \
        ${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/printf "%.0f"
    }

    # Helper: get max from comma-separated values
    get_max() {
      echo "$1" | ${pkgs.coreutils}/bin/tr ',' '\n' | ${pkgs.coreutils}/bin/sort -rn | ${pkgs.coreutils}/bin/head -1
    }

    # Main monitoring loop
    echo "Thermal monitor started"
    echo "GPU thresholds: warning=$GPU_WARNING critical=$GPU_CRITICAL emergency=$GPU_EMERGENCY"
    echo "CPU thresholds: warning=$CPU_WARNING critical=$CPU_CRITICAL emergency=$CPU_EMERGENCY"
    echo "Check interval: $CHECK_INTERVAL seconds"

    while true; do
      TIMESTAMP=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')
      STATUS="OK"
      IN_EMERGENCY=false

      # Read temperatures
      GPU_TEMPS=$(get_gpu_temps || echo "N/A")
      GPU_POWERS=$(get_gpu_powers || echo "N/A")
      CPU_TEMP=$(get_cpu_temp || echo "0")

      # Log metrics
      echo "$TIMESTAMP | GPU_TEMPS: $GPU_TEMPS | GPU_POWERS: $GPU_POWERS | CPU_TEMP: $CPU_TEMP" >> "$METRICS_LOG"

      # Check GPU temperatures
      if [ "$GPU_TEMPS" != "N/A" ]; then
        GPU_MAX=$(get_max "$GPU_TEMPS")

        if [ "$GPU_MAX" -ge "$GPU_EMERGENCY" ]; then
          STATUS="EMERGENCY"
          IN_EMERGENCY=true
          echo "[$TIMESTAMP] EMERGENCY: GPU temperature $GPU_MAX°C >= $GPU_EMERGENCY°C"
          notify "critical" "GPU EMERGENCY" "Temperature: $GPU_MAX°C - System may shutdown!"
        elif [ "$GPU_MAX" -ge "$GPU_CRITICAL" ]; then
          STATUS="CRITICAL"
          echo "[$TIMESTAMP] CRITICAL: GPU temperature $GPU_MAX°C >= $GPU_CRITICAL°C"
          notify "critical" "GPU Critical" "Temperature: $GPU_MAX°C"
        elif [ "$GPU_MAX" -ge "$GPU_WARNING" ]; then
          STATUS="WARNING"
          echo "[$TIMESTAMP] WARNING: GPU temperature $GPU_MAX°C >= $GPU_WARNING°C"
          notify "normal" "GPU Warning" "Temperature: $GPU_MAX°C"
        fi
      fi

      # Check CPU temperature
      if [ "$CPU_TEMP" != "0" ] && [ -n "$CPU_TEMP" ]; then
        if [ "$CPU_TEMP" -ge "$CPU_EMERGENCY" ]; then
          STATUS="EMERGENCY"
          IN_EMERGENCY=true
          echo "[$TIMESTAMP] EMERGENCY: CPU temperature $CPU_TEMP°C >= $CPU_EMERGENCY°C"
          notify "critical" "CPU EMERGENCY" "Temperature: $CPU_TEMP°C - System may shutdown!"
        elif [ "$CPU_TEMP" -ge "$CPU_CRITICAL" ]; then
          if [ "$STATUS" != "EMERGENCY" ]; then STATUS="CRITICAL"; fi
          echo "[$TIMESTAMP] CRITICAL: CPU temperature $CPU_TEMP°C >= $CPU_CRITICAL°C"
          notify "critical" "CPU Critical" "Temperature: $CPU_TEMP°C"
        elif [ "$CPU_TEMP" -ge "$CPU_WARNING" ]; then
          if [ "$STATUS" = "OK" ]; then STATUS="WARNING"; fi
          echo "[$TIMESTAMP] WARNING: CPU temperature $CPU_TEMP°C >= $CPU_WARNING°C"
          notify "normal" "CPU Warning" "Temperature: $CPU_TEMP°C"
        fi
      fi

      # Emergency shutdown logic
      if $IN_EMERGENCY; then
        EMERGENCY_COUNT=$((EMERGENCY_COUNT + 1))
        echo "[$TIMESTAMP] Emergency count: $EMERGENCY_COUNT/$EMERGENCY_THRESHOLD"

        if [ "$EMERGENCY_COUNT" -ge "$EMERGENCY_THRESHOLD" ]; then
          echo "[$TIMESTAMP] INITIATING EMERGENCY SHUTDOWN - thermal protection"
          notify "critical" "EMERGENCY SHUTDOWN" "System shutting down in 1 minute due to thermal emergency!"
          ${pkgs.systemd}/bin/shutdown -h +1 "Thermal emergency: temperatures exceeded safe limits"
        fi
      else
        # Reset counter if not in emergency
        if [ "$EMERGENCY_COUNT" -gt 0 ]; then
          echo "[$TIMESTAMP] Emergency condition cleared, resetting counter"
          EMERGENCY_COUNT=0
        fi
      fi

      ${pkgs.coreutils}/bin/sleep "$CHECK_INTERVAL"
    done
  '';
in
{
  options.services.thermal-monitor = {
    enable = lib.mkEnableOption "thermal and power monitoring service";

    checkInterval = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Interval between temperature checks in seconds";
    };

    gpuWarningTemp = lib.mkOption {
      type = lib.types.int;
      default = 78;
      description = "GPU temperature warning threshold (°C)";
    };

    gpuCriticalTemp = lib.mkOption {
      type = lib.types.int;
      default = 85;
      description = "GPU temperature critical threshold (°C)";
    };

    gpuEmergencyTemp = lib.mkOption {
      type = lib.types.int;
      default = 90;
      description = "GPU temperature emergency threshold for shutdown (°C)";
    };

    cpuWarningTemp = lib.mkOption {
      type = lib.types.int;
      default = 80;
      description = "CPU temperature warning threshold (°C)";
    };

    cpuCriticalTemp = lib.mkOption {
      type = lib.types.int;
      default = 90;
      description = "CPU temperature critical threshold (°C)";
    };

    cpuEmergencyTemp = lib.mkOption {
      type = lib.types.int;
      default = 95;
      description = "CPU temperature emergency threshold for shutdown (°C)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure lm_sensors is available
    environment.systemPackages = [ pkgs.lm_sensors ];

    # Main monitoring service
    systemd.services.thermal-monitor = {
      description = "Thermal and Power Monitoring Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = monitorScript;
        Restart = "always";
        RestartSec = 5;

        # Security hardening
        NoNewPrivileges = false;  # Needed for sudo to work for notifications
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/log/thermal-monitor" ];
      };
    };

    # Log rotation timer
    systemd.services.thermal-monitor-logrotate = {
      description = "Rotate thermal monitor logs";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "thermal-logrotate" ''
          LOG_DIR="/var/log/thermal-monitor"
          METRICS_LOG="$LOG_DIR/metrics.log"

          if [ -f "$METRICS_LOG" ]; then
            # Keep last 7 days of logs
            TIMESTAMP=$(${pkgs.coreutils}/bin/date '+%Y%m%d')
            ${pkgs.coreutils}/bin/mv "$METRICS_LOG" "$LOG_DIR/metrics.$TIMESTAMP.log"

            # Delete logs older than 7 days
            ${pkgs.findutils}/bin/find "$LOG_DIR" -name "metrics.*.log" -mtime +7 -delete
          fi
        '';
      };
    };

    systemd.timers.thermal-monitor-logrotate = {
      description = "Daily rotation of thermal monitor logs";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    # Create log directory
    systemd.tmpfiles.rules = [
      "d /var/log/thermal-monitor 0755 root root -"
    ];
  };
}
