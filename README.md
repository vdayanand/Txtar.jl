# Txtar.jl

`Txtar.jl` is a Julia package for handling text archives in the [Txtar format](https://pkg.go.dev/golang.org/x/tools/txtar#hdr-Txtar_format). This package provides functionality to parse, format, and extract content from Txtar archives.

## Installation

To install `Txtar.jl`, you can use the Julia package manager:

```julia
using Pkg
Pkg.add("Txtar")
```

## Overview

A Txtar archive consists of a comment section and a list of files, each with a name and content. This package provides types and functions to work with these archives, including:

- `Archive`: Represents a Txtar archive.
- `File`: Represents a file with a name and content within the archive.
- `extract`: Extracts the files in an `Archive` to a specified directory.
- `format`: Converts an `Archive` to a string in Txtar format.
- `parse`: Parses a string in Txtar format to an `Archive` object.

## Why Txtar?

Txtar is particularly useful when writing unit tests as it allows you to store test cases, expected outputs, and other relevant files in a single, easily readable format. This can simplify test data management and help keep tests self-contained and well-organized.

## Examples

### Creating an Archive

```julia
using Txtar

file1 = File("example1.txt", "Hello, world!")
file2 = File("example2.txt", "Julia is fun!")
archive = Archive("# Example Txtar archive
", [file1, file2])
```

### Formatting an Archive

```julia
formatted_str = format(archive)
println(formatted_str)
```

**Output**:
```
# Example Txtar archive
-- example1.txt --
Hello, world!
-- example2.txt --
Julia is fun!
```

### Parsing an Archive

```julia
txtar_str = """
# Example Txtar archive
-- example1.txt --
Hello, world!
-- example2.txt --
Julia is fun!
"""

parsed_archive = parse(txtar_str)
println(parsed_archive.comment)  # Output: "# Example Txtar archive
"
println(parsed_archive.files[1].name)  # Output: "example1.txt"
```

### Extracting Files

```julia
extract(parsed_archive, "output_directory")
```

This will extract `example1.txt` and `example2.txt` to the `output_directory`.

## Types

### `struct File`

```julia
struct File
    name::String
    content::String
end
```

### `struct Archive`

```julia
struct Archive
    comment::String
    files::Vector{File}
end
```

## Functions

### `extract`

Extracts the files from an `Archive` to a specified directory.

```julia
extract(a::Archive, dir::String=pwd(); strip_leading=true)
```

- **Arguments**:
  - `a::Archive`: The archive to extract.
  - `dir::String`: The target directory for extraction (default is the current working directory).
  - `strip_leading`: Whether to strip leading path separators from file names (default is `true`).

### `format`

Converts an `Archive` object to a string in Txtar format.

```julia
format(a::Archive) -> String
```

- **Returns**: A string representing the archive in Txtar format.

### `parse`

Parses a string in Txtar format into an `Archive` object.

```julia
parse(str::String) -> Archive
```

- **Arguments**:
  - `str::String`: The string in Txtar format to be parsed.
- **Returns**: An `Archive` object.

## License

`Txtar.jl` is open source and available under the MIT License.
