#!/bin/bash

# VI Editor Commands
# Reference: 1_Basic_commands.md

# ============ Basic Commands ============
# Open file in vi editor
# vi filename

# ============ Extended Command Mode (After pressing ESC) ============

# Exit file without saving changes
# :q!

# Save the content in file and exit
# :x
# :wq!

# Set the line number
# :set nu

# ============ Command Mode (Default Mode, ESC) ============

# Move cursor to beginning of the file
# gg

# Move cursor to the end of the file
# G

# Move one word forward
# w

# Move one word backward
# b

# Move n words forward (e.g., 5w moves 5 words forward)
# nw

# Move n words backward
# nb

# Undo the changes
# u

# Redo the changes
# ctrl+r

# Copy the line where the cursor is positioned
# yy

# Copy n lines (e.g., 5yy copies 5 lines from the cursor)
# nyy

# Paste the copied content below the cursor
# p

# Paste the copied content above the cursor
# P

# Delete the entire line where cursor is placed
# dd

# Delete n lines (e.g., 5dd deletes 5 lines from the cursor)
# ndd

# Delete the word where cursor is placed
# dw

# Search the word (Press Enter then 'n' to search the next occurrence)
# /<word>

# ============ Insert Mode (ESC + i) ============
# This mode allows normal text editing
# Press ESC to return to command mode
