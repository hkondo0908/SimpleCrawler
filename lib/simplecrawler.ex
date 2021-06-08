defmodule SimpleCrawler do
  def get_page do
    url = "https://thewaggletraining.github.io/"
    html = HTTPoison.get!(url)
    {:ok, document} = Floki.parse_document(html.body)
    document |> Floki.find("a") |> Floki.attribute("href") 
  end

  def question_one do
    get_page()
    |> Enum.map(&IO.puts(&1))
  end

  def get_nextpage(document) do
    domain = "https://thewaggletraining.github.io/"
    for url <- document do
      html = HTTPoison.get!(url)
      {:ok, doc} = Floki.parse_document(html.body)
      doc |> Floki.find("a") |> Floki.attribute("href") 
      |> Enum.reduce([],&if String.starts_with?(&1,domain) do List.insert_at(&2,0,&1) end)
      |> List.wrap()
    end
  end

  def question_two do
    List.flatten(get_nextpage(get_page()))
  end

  def get_pages(url) do
    domain = "https://thewaggletraining.github.io/"
    html = HTTPoison.get!(url)
    {:ok, document} = Floki.parse_document(html.body)
    lists = document |> Floki.find("a") |> Floki.attribute("href") 
    Enum.reduce(lists,[],&if String.starts_with?(&1,domain) do List.insert_at(&2,0,&1) else &2 end)
    |> List.wrap()
  end 

  def get_repeat(list) do
    new_list = Enum.uniq(list++List.flatten(get_nextpage(list)))
    if list == new_list  do  
        new_list 
    else
       get_repeat(new_list)
    end
  end

  def get_contents(url) do
    html=HTTPoison.get!(url)
    {:ok,document} = Floki.parse_document(html.body)
    document
    |> Floki.find("body")
    |> Floki.text()
    |> String.replace("\n","")
    |> String.replace(" ","")
  end

  def question_three do
    domain = "https://thewaggletraining.github.io/"
    list= List.flatten([domain|get_pages(domain)])
    get_repeat(list)
    |>Enum.map(&IO.puts(get_contents(&1)))
  end

  def question_four do
    domain = "https://thewaggletraining.github.io/"
    filename = "q4.txt"
    list= List.flatten(get_pages(domain))
    contents_list=List.flatten([domain|get_repeat(list)])
    |>Enum.map(&[&1,get_contents(&1)<>"\r\n"])
    File.write(filename,contents_list)
  end

  def question_five do
    domain = "https://thewaggletraining.github.io/"
    filename = "q5.csv"
    list= List.flatten(get_pages(domain))
    contents_list=List.flatten([domain|get_repeat(list)])
    |>Enum.map(&[&1,get_contents(&1)])
    |>CSV.encode(separator: ?\t, delimiter: "\n")
    |>Enum.to_list()
    File.write(filename,contents_list)
  end

  def question_six do
    domain = IO.gets(">")
    |> String.trim
    list= List.flatten(get_pages(domain))
    List.flatten([domain|get_repeat(list)])
  end

end
