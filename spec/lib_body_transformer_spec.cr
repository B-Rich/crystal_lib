require "./spec_helper"

private def assert_transform(header, input, output)
  it "transforms #{input.inspect} in #{header.inspect}" do
    nodes = parse(File.read("#{__DIR__}/headers/#{header}.h"))
    transformer = LibBodyTransformer.new(nodes)

    lib_def = Crystal::Parser.parse(%(
      lib LibSome
        #{input}
      end
    )) as Crystal::LibDef
    lib_def.body = transformer.transform(lib_def.body)
    join_lines(lib_def.to_s).should eq(join_lines("lib LibSome\n#{output}\nend"))
  end
end

private def join_lines(string)
  string.split("\n").map(&.strip).reject(&.empty?).join("\n")
end

describe LibBodyTransformer do
  assert_transform("pcre",
    "INFO_CAPTURECOUNT = PCRE_INFO_CAPTURECOUNT",
    "INFO_CAPTURECOUNT = 2"
  )

  assert_transform("pcre",
    "fun compile = pcre_compile",
    %(
    alias Pcre = Void*
    fun compile = pcre_compile(x0 : LibC::Char*, x1 : LibC::Int, x2 : LibC::Char**, x3 : LibC::Int*, x4 : LibC::UInt8*) : Pcre
    )
  )
end