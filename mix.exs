defmodule Mix.Tasks.Compile.MakeBindings do
  def run(_) do
    {_, exit_code} = System.cmd("make", [], into: IO.stream(:stdio, :line))

    case exit_code do
      0 -> :ok
      _ -> :error
    end
  end
end

defmodule Libsecp256k1.Mixfile do
  use Mix.Project

  def project do
    [
      app: :libsecp256k1,
      version: "0.2.3",
      language: :erlang,
      description: "Erlang NIF bindings for the the libsecp256k1 library",
      package: [
        files: [
          "LICENSE",
          "Makefile",
          "README.md",
          "c_src/build_deps.sh",
          "c_src/libsecp256k1_nif.c",
          "mix.exs",
          "priv/.empty",
          "src/libsecp256k1.erl"
        ],
        maintainers: ["Matthew Branton", "Geoffrey Hayes"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/exthereum/libsecp256k1"}
      ],
      compilers: [:make_bindings, :erlang, :app],
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:crypto]]
  end

  defp deps() do
    [
      {:ex_doc, "~> 0.17", only: :dev, runtime: false}
    ]
  end
end
