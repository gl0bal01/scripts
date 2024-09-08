#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
 This script automates the process of creating a Ghidra project, importing a binary,
 running analysis, and opening the Ghidra GUI for a given file.      
                                          
 gl0bal01 - Ghidra Automation Script
"""

import sys
import click
import subprocess
import select
from pathlib import Path

# Set the path to Ghidra installation
GHIDRA_PATH = Path('/usr/share/ghidra').resolve()

def create_unique_filename(path):
    """Create a unique filename by appending a number if the file already exists."""
    path = Path(path).resolve()
    counter = 0
    while True:
        unique_path = path.with_name(f"{path.stem}_{counter}{path.suffix}" if counter else path.name)
        if not unique_path.exists():
            return unique_path
        counter += 1

def should_run():
    """Prompt user to confirm running the analysis."""
    print('Sure not a Malware? Analysis will start in 3 seconds, press any key and validate to cancel')
    rlist, _, _ = select.select([sys.stdin], [], [], 3.0)
    return not rlist

def run_ghidra(command, *args):
    """Run a Ghidra command with given arguments."""
    full_command = [str(GHIDRA_PATH / command)] + list(args)
    try:
        result = subprocess.run(full_command, check=True, text=True, capture_output=True)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running Ghidra command: {e}")
        print(e.stdout)
        print(e.stderr)
        sys.exit(1)

@click.command()
@click.argument('filename', type=click.Path(exists=True))
def main(filename):
    """Main function to handle Ghidra project creation and analysis."""
    filename = Path(filename).resolve()

    if filename.is_dir():
        return run_ghidra('ghidraRun')

    if filename.suffix == '.gpr':
        return run_ghidra('ghidraRun', str(filename))

    out_dir = filename.parent
    proj_file = create_unique_filename(out_dir / f"{filename.name}.gpr")
    proj_name = proj_file.stem

    # Display file information
    file_output = subprocess.check_output(['file', str(filename)], text=True)
    print(file_output)

    if should_run():
        # Run Ghidra analysis
        run_ghidra('support/analyzeHeadless', str(out_dir), proj_name, '-import', str(filename))
        # Open Ghidra GUI
        run_ghidra('ghidraRun', str(proj_file))

if __name__ == '__main__':
    main()