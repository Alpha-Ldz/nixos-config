#!/usr/bin/env python3
"""
Convert color theme from .conf format to macOS .terminal format
"""

import plistlib
import re
from pathlib import Path


def hex_to_rgb(hex_color):
    """Convert hex color to RGB values (0-1 range)"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) / 255.0 for i in (0, 2, 4))


def create_nscolor_data(r, g, b, a=1.0):
    """
    Create NSColor archived data in the format expected by Terminal.app
    """
    # Create the color string in the format used by Terminal.app
    color_string = f"{r} {g} {b} {a}"

    # Build the archived object structure
    archived = {
        '$version': 100000,
        '$archiver': 'NSKeyedArchiver',
        '$top': {'root': plistlib.UID(1)},
        '$objects': [
            '$null',
            {
                '$class': plistlib.UID(2),
                'NSColorSpace': 1,  # NSCalibratedRGBColorSpace
                'NSComponents': color_string.encode('utf-8')
            },
            {
                '$classname': 'NSColor',
                '$classes': ['NSColor', 'NSObject']
            }
        ]
    }

    # Serialize to binary plist
    return plistlib.dumps(archived, fmt=plistlib.FMT_BINARY)


def parse_conf_file(conf_path):
    """Parse a .conf file and extract colors"""
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


def create_terminal_theme(name, colors):
    """Create a .terminal plist dictionary from colors"""
    theme = {
        'name': name,
        'type': 'Window Settings',
        'ProfileCurrentVersion': 2.07,
        'FontAntialias': True,
        'FontWidthSpacing': 1.0,
        'columnCount': 120,
        'rowCount': 40,
        'shellExitAction': 1,
        'useOptionAsMetaKey': True,
    }

    # Background color
    if 'background' in colors:
        r, g, b = hex_to_rgb(colors['background'])
        theme['BackgroundColor'] = create_nscolor_data(r, g, b)

    # Text color (foreground)
    if 'foreground' in colors:
        r, g, b = hex_to_rgb(colors['foreground'])
        theme['TextColor'] = create_nscolor_data(r, g, b)
        theme['TextBoldColor'] = create_nscolor_data(1.0, 1.0, 1.0)  # White for bold

    # Cursor color
    if 'cursor' in colors:
        r, g, b = hex_to_rgb(colors['cursor'])
        theme['CursorColor'] = create_nscolor_data(r, g, b)

    # Selection color
    if 'selection_background' in colors:
        r, g, b = hex_to_rgb(colors['selection_background'])
        theme['SelectionColor'] = create_nscolor_data(r, g, b)

    # ANSI colors (0-15)
    ansi_mapping = {
        'color0': 'ANSIBlackColor',
        'color1': 'ANSIRedColor',
        'color2': 'ANSIGreenColor',
        'color3': 'ANSIYellowColor',
        'color4': 'ANSIBlueColor',
        'color5': 'ANSIMagentaColor',
        'color6': 'ANSICyanColor',
        'color7': 'ANSIWhiteColor',
        'color8': 'ANSIBrightBlackColor',
        'color9': 'ANSIBrightRedColor',
        'color10': 'ANSIBrightGreenColor',
        'color11': 'ANSIBrightYellowColor',
        'color12': 'ANSIBrightBlueColor',
        'color13': 'ANSIBrightMagentaColor',
        'color14': 'ANSIBrightCyanColor',
        'color15': 'ANSIBrightWhiteColor',
    }

    for conf_key, terminal_key in ansi_mapping.items():
        if conf_key in colors:
            r, g, b = hex_to_rgb(colors[conf_key])
            theme[terminal_key] = create_nscolor_data(r, g, b)

    return theme


def main():
    script_dir = Path(__file__).parent

    # Convert Bluloco Dark
    dark_colors = parse_conf_file(script_dir / 'bluloco-dark.conf')
    dark_theme = create_terminal_theme('Bluloco Dark', dark_colors)

    with open(script_dir / 'Bluloco-Dark.terminal', 'wb') as f:
        plistlib.dump(dark_theme, f, fmt=plistlib.FMT_XML)

    print("✓ Created Bluloco-Dark.terminal")
    print(f"  Foreground: {dark_colors.get('foreground')}")
    print(f"  Background: {dark_colors.get('background')}")

    # Convert Bluloco Light
    light_colors = parse_conf_file(script_dir / 'bluloco-light.conf')
    light_theme = create_terminal_theme('Bluloco Light', light_colors)

    with open(script_dir / 'Bluloco-Light.terminal', 'wb') as f:
        plistlib.dump(light_theme, f, fmt=plistlib.FMT_XML)

    print("\n✓ Created Bluloco-Light.terminal")
    print(f"  Foreground: {light_colors.get('foreground')}")
    print(f"  Background: {light_colors.get('background')}")

    print("\nTo import in Terminal.app:")
    print("1. Copy these .terminal files to your Mac")
    print("2. Double-click each file to import, OR")
    print("3. Open Terminal.app > Preferences > Profiles")
    print("4. Click the gear icon > Import...")
    print("5. Select the .terminal files")


if __name__ == '__main__':
    main()
