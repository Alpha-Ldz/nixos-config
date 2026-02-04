#!/usr/bin/env python3
"""
Fix NSColor format to match what Terminal.app expects
Based on analysis of working Grass.terminal file
"""

import plistlib
import re
from pathlib import Path


def hex_to_rgb_normalized(hex_color):
    """Convert hex to normalized RGB (0-1 range)"""
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16) / 255.0
    g = int(hex_color[2:4], 16) / 255.0
    b = int(hex_color[4:6], 16) / 255.0
    return (r, g, b)


def create_nscolor_correct(r, g, b):
    """
    Create NSColor with CORRECT format that Terminal.app expects:
    - NSColorSpace = 2 (Device RGB, not Calibrated RGB)
    - Use 'NSRGB' key (not 'NSComponents')
    - Only 3 values (RGB, no alpha)
    - Null-terminated string
    """
    # Format: "R G B\x00" (null-terminated, no alpha!)
    rgb_string = f"{r} {g} {b}\x00"

    archived = {
        '$version': 100000,
        '$archiver': 'NSKeyedArchiver',
        '$top': {'root': plistlib.UID(1)},
        '$objects': [
            '$null',
            {
                'NSRGB': rgb_string.encode('utf-8'),
                'NSColorSpace': 2,  # Device RGB (not 1 = Calibrated RGB)
                '$class': plistlib.UID(2)
            },
            {
                '$classname': 'NSColor',
                '$classes': ['NSColor', 'NSObject']
            }
        ]
    }

    return plistlib.dumps(archived, fmt=plistlib.FMT_BINARY)


def parse_conf_colors(conf_path):
    """Parse .conf file for colors"""
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


def create_font_data(font_name="Courier", size=13.0):
    """Create NSFont data (same as Grass.terminal uses)"""
    archived = {
        '$version': 100000,
        '$archiver': 'NSKeyedArchiver',
        '$top': {'root': plistlib.UID(1)},
        '$objects': [
            '$null',
            {
                '$class': plistlib.UID(3),
                'NSName': plistlib.UID(2),
                'NSSize': size,
                'NSfFlags': 16
            },
            font_name,
            {
                '$classname': 'NSFont',
                '$classes': ['NSFont', 'NSObject']
            }
        ]
    }
    return plistlib.dumps(archived, fmt=plistlib.FMT_BINARY)


def main():
    script_dir = Path(__file__).parent

    # Parse color configs
    dark_colors = parse_conf_colors(script_dir / 'bluloco-dark.conf')
    light_colors = parse_conf_colors(script_dir / 'bluloco-light.conf')

    # ANSI color mapping
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

    # Create Bluloco Dark theme
    print("=== Creating Bluloco Dark ===")
    dark_theme = {
        'name': 'Bluloco Dark',
        'type': 'Window Settings',
        'ProfileCurrentVersion': 2.09,
        'FontAntialias': True,
        'Font': create_font_data("Menlo-Regular", 12.0),
    }

    # Add colors with CORRECT format
    if 'background' in dark_colors:
        r, g, b = hex_to_rgb_normalized(dark_colors['background'])
        dark_theme['BackgroundColor'] = create_nscolor_correct(r, g, b)
        print(f"  Background: {dark_colors['background']} -> RGB({r:.4f}, {g:.4f}, {b:.4f})")

    if 'foreground' in dark_colors:
        r, g, b = hex_to_rgb_normalized(dark_colors['foreground'])
        dark_theme['TextColor'] = create_nscolor_correct(r, g, b)
        dark_theme['TextBoldColor'] = create_nscolor_correct(1.0, 1.0, 1.0)
        print(f"  Foreground: {dark_colors['foreground']} -> RGB({r:.4f}, {g:.4f}, {b:.4f})")

    if 'cursor' in dark_colors:
        r, g, b = hex_to_rgb_normalized(dark_colors['cursor'])
        dark_theme['CursorColor'] = create_nscolor_correct(r, g, b)

    if 'selection_background' in dark_colors:
        r, g, b = hex_to_rgb_normalized(dark_colors['selection_background'])
        dark_theme['SelectionColor'] = create_nscolor_correct(r, g, b)

    # Add ANSI colors
    for conf_key, term_key in ansi_mapping.items():
        if conf_key in dark_colors:
            r, g, b = hex_to_rgb_normalized(dark_colors[conf_key])
            dark_theme[term_key] = create_nscolor_correct(r, g, b)

    # Add extra settings from Grass.terminal
    dark_theme['CursorType'] = 0
    dark_theme['columnCount'] = 120
    dark_theme['rowCount'] = 40
    dark_theme['shellExitAction'] = 1
    dark_theme['useOptionAsMetaKey'] = True

    # Save
    with open(script_dir / 'Bluloco-Dark.terminal', 'wb') as f:
        plistlib.dump(dark_theme, f, fmt=plistlib.FMT_XML)

    print("✅ Created Bluloco-Dark.terminal with CORRECT NSColor format")

    # Create Bluloco Light theme
    print("\n=== Creating Bluloco Light ===")
    light_theme = {
        'name': 'Bluloco Light',
        'type': 'Window Settings',
        'ProfileCurrentVersion': 2.09,
        'FontAntialias': True,
        'Font': create_font_data("Menlo-Regular", 12.0),
    }

    if 'background' in light_colors:
        r, g, b = hex_to_rgb_normalized(light_colors['background'])
        light_theme['BackgroundColor'] = create_nscolor_correct(r, g, b)
        print(f"  Background: {light_colors['background']} -> RGB({r:.4f}, {g:.4f}, {b:.4f})")

    if 'foreground' in light_colors:
        r, g, b = hex_to_rgb_normalized(light_colors['foreground'])
        light_theme['TextColor'] = create_nscolor_correct(r, g, b)
        light_theme['TextBoldColor'] = create_nscolor_correct(0.0, 0.0, 0.0)
        print(f"  Foreground: {light_colors['foreground']} -> RGB({r:.4f}, {g:.4f}, {b:.4f})")

    if 'cursor' in light_colors:
        r, g, b = hex_to_rgb_normalized(light_colors['cursor'])
        light_theme['CursorColor'] = create_nscolor_correct(r, g, b)

    if 'selection_background' in light_colors:
        r, g, b = hex_to_rgb_normalized(light_colors['selection_background'])
        light_theme['SelectionColor'] = create_nscolor_correct(r, g, b)

    for conf_key, term_key in ansi_mapping.items():
        if conf_key in light_colors:
            r, g, b = hex_to_rgb_normalized(light_colors[conf_key])
            light_theme[term_key] = create_nscolor_correct(r, g, b)

    light_theme['CursorType'] = 0
    light_theme['columnCount'] = 120
    light_theme['rowCount'] = 40
    light_theme['shellExitAction'] = 1
    light_theme['useOptionAsMetaKey'] = True

    with open(script_dir / 'Bluloco-Light.terminal', 'wb') as f:
        plistlib.dump(light_theme, f, fmt=plistlib.FMT_XML)

    print("✅ Created Bluloco-Light.terminal with CORRECT NSColor format")

    print("\n" + "="*60)
    print("✅ DONE! Files regenerated with CORRECT format")
    print("="*60)
    print("\n📋 Key fixes applied:")
    print("  ✓ NSColorSpace: 2 (Device RGB, was 1)")
    print("  ✓ Key: 'NSRGB' (was 'NSComponents')")
    print("  ✓ Format: 3 values RGB only (was 4 values RGBA)")
    print("  ✓ Null-terminated strings")
    print("\n🎯 These files should now work correctly on macOS!")
    print("   Import them again: double-click or use Preferences > Import")


if __name__ == '__main__':
    main()
