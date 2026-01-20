{ pkgs, ... }:
{
  # Kubernetes tools
  programs.k9s = {
    enable = true;

    skins = {
      bluloco-dark = {
        k9s = {
          body = {
            fgColor = "#cdd3e0";
            bgColor = "#282c34";
            logoColor = "#10b0fe";
          };

          prompt = {
            fgColor = "#cdd3e0";
            bgColor = "#282c34";
            suggestColor = "#8f9aae";
          };

          info = {
            fgColor = "#10b0fe";
            sectionColor = "#10b0fe";
          };

          dialog = {
            fgColor = "#cdd3e0";
            bgColor = "#282c34";
            buttonFgColor = "#282c34";
            buttonBgColor = "#10b0fe";
            buttonFocusFgColor = "#282c34";
            buttonFocusBgColor = "#ffcc00";
            labelFgColor = "#ff9369";
            fieldFgColor = "#cdd3e0";
          };

          frame = {
            border = {
              fgColor = "#42444d";
              focusColor = "#10b0fe";
            };
            menu = {
              fgColor = "#cdd3e0";
              keyColor = "#ff78f8";
              numKeyColor = "#ff78f8";
            };
            crumbs = {
              fgColor = "#cdd3e0";
              bgColor = "#282c34";
              activeColor = "#10b0fe";
            };
            status = {
              newColor = "#3fc56a";
              modifyColor = "#10b0fe";
              addColor = "#3fc56a";
              errorColor = "#fc2e51";
              highlightcolor = "#ffcc00";
              killColor = "#8f9aae";
              completedColor = "#8f9aae";
            };
            title = {
              fgColor = "#cdd3e0";
              bgColor = "#282c34";
              highlightColor = "#10b0fe";
              counterColor = "#ff78f8";
              filterColor = "#ff78f8";
            };
          };

          views = {
            charts = {
              bgColor = "#282c34";
              defaultDialColors = [ "#10b0fe" "#fc2e51" ];
              defaultChartColors = [ "#10b0fe" "#fc2e51" ];
            };
            table = {
              fgColor = "#cdd3e0";
              bgColor = "#282c34";
              cursorFgColor = "#282c34";
              cursorBgColor = "#ffcc00";
              markColor = "#ff78f8";
              header = {
                fgColor = "#10b0fe";
                bgColor = "#282c34";
                sorterColor = "#5fb9bc";
              };
            };
            xray = {
              fgColor = "#cdd3e0";
              bgColor = "#282c34";
              cursorColor = "#ffcc00";
              graphicColor = "#10b0fe";
              showIcons = false;
            };
            yaml = {
              keyColor = "#ff78f8";
              colonColor = "#9f7efe";
              valueColor = "#cdd3e0";
            };
            logs = {
              fgColor = "#cdd3e0";
              bgColor = "#282c34";
              indicator = {
                fgColor = "#cdd3e0";
                bgColor = "#282c34";
                toggleOnColor = "#3fc56a";
                toggleOffColor = "#8f9aae";
              };
            };
          };
        };
      };
    };

    settings = {
      k9s = {
        liveViewAutoRefresh = false;
        gpuVendors = {};
        screenDumpDir = "/home/peuleu/.local/state/k9s/screen-dumps";
        refreshRate = 2;
        apiServerTimeout = "2m0s";
        maxConnRetry = 5;
        readOnly = false;
        noExitOnCtrlC = false;
        portForwardAddress = "localhost";
        ui = {
          skin = "bluloco-dark";
          enableMouse = false;
          headless = false;
          logoless = false;
          crumbsless = false;
          splashless = false;
          reactive = false;
          noIcons = false;
          defaultsToFullScreen = false;
          useFullGVRTitle = false;
        };
        skipLatestRevCheck = false;
        disablePodCounting = false;
        shellPod = {
          image = "busybox:1.35.0";
          namespace = "default";
          limits = {
            cpu = "100m";
            memory = "100Mi";
          };
        };
        imageScans = {
          enable = false;
          exclusions = {
            namespaces = [];
            labels = {};
          };
        };
        logger = {
          tail = 100;
          buffer = 5000;
          sinceSeconds = -1;
          textWrap = false;
          disableAutoscroll = false;
          showTime = false;
        };
        thresholds = {
          cpu = {
            critical = 90;
            warn = 70;
          };
          memory = {
            critical = 90;
            warn = 70;
          };
        };
        defaultView = "";
      };
    };
  };
}
