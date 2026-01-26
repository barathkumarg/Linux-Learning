#!/bin/bash

# File Compression and Archive Operations
# Reference: 1_Basic_commands.md

# ============ TAR - Tape Archive ============

# Create a tar archive
tar -cvf archive.tar file1 file2 directory/

# Create a compressed tar archive (.tar.gz)
tar -czvf archive.tar.gz file1 file2 directory/

# Extract a tar archive
tar -xvf archive.tar

# Extract a compressed tar archive
tar -xzvf archive.tar.gz

# List contents of tar archive without extracting
tar -tvf archive.tar

# ============ GZIP - GNU Zip ============

# Compress a file
gzip filename

# Compress multiple files (creates separate .gz files)
gzip file1 file2 file3

# Decompress a file
gunzip filename.gz

# Or use gzip with -d flag
gzip -d filename.gz

# ============ BZIP2 - Burrows Wheeler Zip ============

# Compress a file with bzip2
bzip2 filename

# Decompress a bzip2 file
bunzip2 filename.bz2

# Or use bzip2 with -d flag
bzip2 -d filename.bz2

# ============ ZIP - Zip Archive ============

# Create a zip archive
zip archive.zip file1 file2

# Zip a directory recursively
zip -r archive.zip directory/

# Unzip an archive
unzip archive.zip

# List contents without extracting
unzip -l archive.zip

# ============ Common Tar Flags ============
# c - create archive
# x - extract archive
# v - verbose (show files being processed)
# f - specify filename
# z - use gzip compression
# j - use bzip2 compression
# w - ask for confirmation
# r - append to archive

echo "Compression examples completed!"
