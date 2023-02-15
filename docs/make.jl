using PredNets
using Documenter

cd("docs")

DocMeta.setdocmeta!(PredNets, :DocTestSetup, :(using PredNets); recursive=true)

makedocs(;
    modules=[PredNets],
    authors="Jan Perina <perinja2@gmail.com>",
    repo="https://github.com/B0B36JUL-FinalProjects-2022/Projekt_perinja2/blob/{commit}{path}#{line}",
    sitename="PredNets.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/B0B36JUL-FinalProjects-2022/Projekt_perinja2.git"
)