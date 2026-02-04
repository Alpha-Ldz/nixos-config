#!/usr/bin/env python3
"""
Fix Terminal.app themes by directly modifying color values in existing files
This ensures the binary plist format is exactly what Terminal.app expects
"""

import plistlib
import subprocess
import re
from pathlib import Path


def hex_to_rgb_string(hex_color):
    """Convert hex color to RGB string for NSColor (0-1 range)"""
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16) / 255.0
    g = int(hex_color[2:4], 16) / 255.0
    b = int(hex_color[4:6], 16) / 255.0
    return f"{r} {g} {b} 1.0"


def update_color_in_nscolor(nscolor_data, new_rgb_string):
    """Update the RGB values in an NSColor archived data"""
    try:
        # Decode the NSColor archive
        decoded = plistlib.loads(nscolor_data, fmt=plistlib.FMT_BINARY)

        # Find and update the NSComponents
        for obj in decoded['$objects']:
            if isinstance(obj, dict) and 'NSComponents' in obj:
                obj['NSComponents'] = new_rgb_string.encode('utf-8')
                break

        # Re-encode
        return plistlib.dumps(decoded, fmt=plistlib.FMT_BINARY)
    except Exception as e:
        print(f"Error updating color: {e}")
        return nscolor_data


def parse_conf_colors(conf_path):
    """Parse color definitions from .conf file"""
    colors = {}
    with open(conf_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            match = re.match(r'(\w+)\s+(#[0-9a-fA-F]{6})', line)
            if match:
                key, value = match.groups()
                colors[key] = value
    return colors


def main():
    script_dir = Path(__file__).parent

    # Get the original working file from git
    result = subprocess.run(
        ['git', 'show', '3b13182:home/programs/shell/Bluloco-Dark.terminal'],
        capture_output=True,
        cwd=script_dir
    )

    if result.returncode != 0:
        print("❌ Could not get original file from git")
        print("Using current file as base instead...")
        with open(script_dir / 'Bluloco-Dark.terminal', 'rb') as f:
            original_dark = plistlib.load(f)
    else:
        original_dark = plistlib.loads(result.stdout)

    # Get Bluloco Light original
    result = subprocess.run(
        ['git', 'show', '3b13182:home/programs/shell/Bluloco-Light.terminal'],
        capture_output=True,
        cwd=script_dir
    )

    if result.returncode != 0:
        print("Using current file as base for Light theme...")
        with open(script_dir / 'Bluloco-Light.terminal', 'rb') as f:
            original_light = plistlib.load(f)
    else:
        original_light = plistlib.loads(result.stdout)

    # Parse our .conf files
    dark_colors = parse_conf_colors(script_dir / 'bluloco-dark.conf')
    light_colors = parse_conf_colors(script_dir / 'bluloco-light.conf')

    print("=== Updating Bluloco Dark ===")
    print(f"Background: {dark_colors.get('background')}")
    print(f"Foreground: {dark_colors.get('foreground')}")

    # Update Dark theme colors
    if 'background' in dark_colors:
        rgb_string = hex_to_rgb_string(dark_colors['background'])
        original_dark['BackgroundColor'] = update_color_in_nscolor(
            original_dark['BackgroundColor'], rgb_string)

    if 'foreground' in dark_colors:
        rgb_string = hex_to_rgb_string(dark_colors['foreground'])
        original_dark['TextColor'] = update_color_in_nscolor(
            original_dark['TextColor'], rgb_string)

    if 'cursor' in dark_colors:
        rgb_string = hex_to_rgb_string(dark_colors['cursor'])
        original_dark['CursorColor'] = update_color_in_nscolor(
            original_dark['CursorColor'], rgb_string)

    if 'selection_background' in dark_colors:
        rgb_string = hex_to_rgb_string(dark_colors['selection_background'])
        original_dark['SelectionColor'] = update_color_in_nscolor(
            original_dark['SelectionColor'], rgb_string)

    # Update ANSI colors
    ansi_mapping = {
        'color0': 'ANSIBlackColor', 'color1': 'ANSIRedColor',
        'color2': 'ANSIGreenColor', 'color3': 'ANSIYellowColor',
        'color4': 'ANSIBlueColor', 'color5': 'ANSIMagentaColor',
        'color6': 'ANSICyanColor', 'color7': 'ANSIWhiteColor',
        'color8': 'ANSIBrightBlackColor', 'color9': 'ANSIBrightRedColor',
        'color10': 'ANSIBrightGreenColor', 'color11': 'ANSIBrightYellowColor',
        'color12': 'ANSIBrightBlueColor', 'color13': 'ANSIBrightMagentaColor',
        'color14': 'ANSIBrightCyanColor', 'color15': 'ANSIBrightWhiteColor',
    }

    for conf_key, term_key in ansi_mapping.items():
        if conf_key in dark_colors and term_key in original_dark:
            rgb_string = hex_to_rgb_string(dark_colors[conf_key])
            original_dark[term_key] = update_color_in_nscolor(
                original_dark[term_key], rgb_string)

    # Save Dark theme
    with open(script_dir / 'Bluloco-Dark.terminal', 'wb') as f:
        plistlib.dump(original_dark, f, fmt=plistlib.FMT_XML)

    print("✓ Updated Bluloco-Dark.terminal")

    print("\n=== Updating Bluloco Light ===")
    print(f"Background: {light_colors.get('background')}")
    print(f"Foreground: {light_colors.get('foreground')}")

    # Update Light theme colors (same process)
    if 'background' in light_colors:
        rgb_string = hex_to_rgb_string(light_colors['background'])
        original_light['BackgroundColor'] = update_color_in_nscolor(
            original_light['BackgroundColor'], rgb_string)

    if 'foreground' in light_colors:
        rgb_string = hex_to_rgb_string(light_colors['foreground'])
        original_light['TextColor'] = update_color_in_nscolor(
            original_light['TextColor'], rgb_string)

    if 'cursor' in light_colors:
        rgb_string = hex_to_rgb_string(light_colors['cursor'])
        original_light['CursorColor'] = update_color_in_nscolor(
            original_light['CursorColor'], rgb_string)

    if 'selection_background' in light_colors:
        rgb_string = hex_to_rgb_string(light_colors['selection_background'])
        original_light['SelectionColor'] = update_color_in_nscolor(
            original_light['SelectionColor'], rgb_string)

    for conf_key, term_key in ansi_mapping.items():
        if conf_key in light_colors and term_key in original_light:
            rgb_string = hex_to_rgb_string(light_colors[conf_key])
            original_light[term_key] = update_color_in_nscolor(
                original_light[term_key], rgb_string)

    # Save Light theme
    with open(script_dir / 'Bluloco-Light.terminal', 'wb') as f:
        plistlib.dump(original_light, f, fmt=plistlib.FMT_XML)

    print("✓ Updated Bluloco-Light.terminal")

    print("\n✅ Done! .terminal files have been updated.")
    print("\n📋 To import on your Mac:")
    print("   1. Copy the .terminal files to your Mac")
    print("   2. Double-click each file")
    print("   3. OR: open Terminal.app > Preferences > Profiles > Import...")


if __name__ == '__main__':
    main()
