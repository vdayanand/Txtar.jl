module Txtar
# spec: https://pkg.go.dev/golang.org/x/tools/txtar#hdr-Txtar_format

struct File
    name::String
    content::String
end

struct Archive
	comment::String
	files::Vector{File}
end

"""
    extract(a::Archive, dir::String=pwd(); strip_leading=true)

Extracts the files contained in an `Archive` object `a` to the specified directory `dir`.

# Arguments
- `a::Archive`: The archive object containing the files to be extracted.
- `dir::String`: The target directory where the files will be extracted. Defaults to the current working directory.
- `strip_leading::Bool`: A keyword argument indicating whether leading directory components in file paths should be stripped. Defaults to `true`.
"""
function extract(a::Archive, dir::String=pwd(); strip_leading=true)
    for f in a.files
        fpath = f.name
        if strip_leading
            sc = if Sys.iswindows()
                '\\'
            else
                '/'
            end
            fpath = lstrip(f.name, sc)
        end
        r = tempname()
        open(r, "w") do fd
            write(fd, f.content)
        end
        fp = joinpath(dir, fpath)
        dname = dirname(fp)
        mkpath(dname)
        mv(r, fp; force=true)
    end
end

function ser_content(arr::Vector{AbstractString})
    content = join(arr, '\n')
    if !isempty(content) && !endswith(content, '\n')
        content = content * "\n"
    end
    content
end

"""
    format(a::Archive) -> String

Formats the contents of an `Archive` object `a` into a single string representation.
"""
function format(a::Archive)
    str = ""
    str *= a.comment
    for f in a.files
        str *= "-- $(f.name) --\n"
        str *= f.content
    end
    return str
end

"""
 parse(str) -> Archive

Parses a formatted string representation of an archive into an `Archive` object, containing the archive's comment and a collection of `File` objects.
"""
function parse(str)
    clines = AbstractString[]
    ##nomerge: do better
    name_f = r"^-- (.+) --$"
    files = File[]
    current_file = nothing
    flines = AbstractString[]
    for line in split(str, "\n")
        mtch = match(name_f, line)
        if !isnothing(mtch)
            # store current_file and reset state
            if !isnothing(current_file)
                push!(files, File(current_file, ser_content(flines)))
            end
            current_file = mtch.captures[1]
            flines = AbstractString[]
            continue
        end
        if isnothing(current_file)
            push!(clines, line)
        else
            push!(flines, line)
        end
    end
    if !isnothing(current_file)
        push!(files, File(current_file, ser_content(flines)))
    end
    Archive(ser_content(clines), files)
end

end # module
