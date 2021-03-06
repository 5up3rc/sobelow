defmodule Mix.Tasks.Sobelow do
  use Mix.Task
  @moduledoc """
  Sobelow is a static analysis tool for discovering
  vulnerabilities in Phoenix applications.

  This tool should be run in the root of the project directory
  with the following command:

      mix sobelow

  ## Command line options

  * `--root -r` - Specify application root directory
  * `--with-code -v` - Print vulnerable code snippets
  * `--ignore -i` - Ignore modules
  * `--details -d` - Get module details
  * `--all-details` - Get all module details
  * `--private` - Skip update checks

  ## Ignoring modules

  If specific modules, or classes of modules are not relevant
  to the scan, it is possible to ignore them with a
  comma-separated list.

      mix sobelow -i XSS.Raw,Traversal

  ## Supported modules

  * XSS
  * XSS.Raw
  * XSS.SendResp
  * SQL
  * SQL.Inject
  * Config
  * Config.CSRF
  * Config.HTTPS
  * Config.Secrets
  * Traversal
  * Traversal.SendFile
  * Traversal.FileModule
  * Misc
  * Misc.BinToTerm
  * CI
  * CI.System
  * CI.OS

  """
  @switches [with_code: :boolean,
             root: :string,
             ignore: :string,
             details: :string,
             all_details: :boolean,
             private: :boolean]

  @aliases  [v: :with_code, r: :root, i: :ignore, d: :details]

  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, aliases: @aliases, switches: @switches)

    with_code = Keyword.get(opts, :with_code, false)
    root = Keyword.get(opts, :root, ".")
    details = Keyword.get(opts, :details, nil)
    all_details = Keyword.get(opts, :all_details)
    private = Keyword.get(opts, :private, false)

    set_env(:with_code, with_code)
    set_env(:root, root)
    set_env(:details, details)
    set_env(:private, private)

    ignored =
      Keyword.get(opts, :ignore, "")
      |> String.split(",")

    set_env(:ignored, ignored)

    if !is_nil(all_details) do
      Sobelow.all_details()
    end

    if is_nil(all_details) && !is_nil(details) do
      Sobelow.details()
    end

    if is_nil(all_details) && is_nil(details) do
      Sobelow.run()
    end

  end

  def set_env(key, value) do
    Application.put_env(:sobelow, key, value)
  end
end