using Test
using Txtar: Archive, extract, parse, File, format

@testset "Txtar unit tests" begin
    @testset "parser" begin
        s = """comment1
comment2
-- file1 --
File 1 text.
-- foo ---
More file 1 text.
-- file 2 --
File 2 text.
-- empty --
-- noNL --
hello world
-- empty filename line --
some content
-- --
"""
        parsed = parse(s)
        expected = Archive("comment1\ncomment2\n",
                                  [
                                      File("file1", "File 1 text.\n-- foo ---\nMore file 1 text.\n"),
                                      File("file 2", "File 2 text.\n"),
                                      File("empty", ""),
                                      File("noNL", "hello world\n"),
                                      File("empty filename line", "some content\n-- --\n")
                                  ]
                           )
        @test parsed.comment == "comment1\ncomment2\n"
        @test parsed.files[1].name == "file1"
        @test parsed.files[1].content == "File 1 text.\n-- foo ---\nMore file 1 text.\n"

        @test parsed.files[2].name == "file 2"
        @test parsed.files[2].content == "File 2 text.\n"

        @test parsed.files[3].name == "empty"
        @test parsed.files[3].content == ""

        @test parsed.files[4].name == "noNL"
        @test parsed.files[4].content == "hello world\n"

        @test parsed.files[5].name == "empty filename line"
        @test parsed.files[5].content == "some content\n-- --\n"
    end
    @testset "format" begin
        expected = """comment1
comment2
-- file1 --
File 1 text.
-- foo ---
More file 1 text.
-- file 2 --
File 2 text.
-- empty --
-- noNL --
hello world"""
        a = Archive("comment1\ncomment2\n", [File(
            "file1", "File 1 text.\n-- foo ---\nMore file 1 text.\n"
        ),File(
            "file 2", "File 2 text.\n"
        ), File("empty", ""), File("noNL", "hello world")])
        @test format(a) == expected
    end
    @testset "extract" begin
        a = Archive("comment1\ncomment2\n", [File(
            "file1", "File 1 text.\n-- foo ---\nMore file 1 text.\n"
        ),File(
            "file 2", "File 2 text.\n"
        ), File("empty", ""), File("noNL", "hello world"), File("/t", "")])
        mktempdir() do tmp
            extract(a, tmp)
            for f in a.files
                a = if Sys.iswindows()
                    '\\'
                else
                    '/'
                end
                file = joinpath(tmp, lstrip(f.name, a))
                @test isfile(file)
                @test f.content == read(file, String)
            end
        end
    end
end
