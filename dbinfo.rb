#!/usr/bin/env ruby
# frozen_string_literal: true
require "pry"

class Id
  @@count = 6                                         # 1st 6 used in DATA
  def initialize(n=nil)
    @@count += 1 unless n
    @n = n ? n : @@count
  end
  def to_s; "!#@n" end
end

class DBInfo
  attr_accessor :id
  def initialize; @id = Id.new; end
end

class TypeSet < DBInfo
  def initialize(types=[]); super(); @ids = []; end
  def to_s; "#{@id} = !{#{@ids.map(&:to_s).join(' ')}}"; end
end
  
class FunType < DBInfo
  def initialize(types); super(); @type_id = TypeSet.new(types); end
  def to_s; "#{@id} = !DISubroutineType(#{@type_id})"
  end
end

class Fun < DBInfo
  def initialize(name, line)
    super()
    @name, @line = name, line
  end
  def to_s
    "#{@id} = distinct !DISubprogram(name: \"#{@name}\", line: #{@line}, " +
      "scope: !1, file: !1, isLocal: false, isDefinition: true, " +
      "scopeLine: #{@line}, isOptimized: false, " +
      "flags: DIFlagPrototyped, unit: !0, variables: !2)"
  end
end

class TBasic < DBInfo
  KINDS = {
    :i64 => "name: \"int\", size: 64, encoding: DW_ATE_signed",
    :i1 => "name: \"bool\", size: 1, encoding: DW_ATE_boolean",
    :i8 => "name: \"char\", size: 8, encoding: DW_ATE_signed_char"
  }
  def initialize(kind)
    super()
    @desc = KINDS.has_key?(kind) ? KINDS[kind] : KINDS[:i8]
  end
  def to_s; "#{@id} = !DIBasicType(#{@desc})" end
end

class TDerived < DBInfo
  def initialize(base, tag=:DW_TAG_pointer_type, size=64)
    super()
    @base, @tag, @size = base, tag, size
  end
  def to_s
    "#{@id} = !DIDerivedType(tag: #{@tag}, size: #{@size}, baseType: #{@base})"
  end
end

class Var < DBInfo
  def initialize(name, type, line, scope, arg=1)
    super()
    @name, @type, @line, @scope, @arg = name, type, line, scope, arg
  end
  def to_s
    "#{@id} = !DILocalVariable(name: \"#{@name}\", type: #{@type}, " +
      "scope: #{@scope}, file: !1, line: #{@line})" # , arg: #{@arg})"
  end
end

class Loc < DBInfo
  def initialize(line, scope, col=1)
    super()
    @line, @scope, @col = line, scope, col
  end
  def to_s
    "#{@id} = !DILocation(line: #{@line}, column: #{@col}, scope: #{@scope})"
  end
end

# Parse lines from .ll file
class LLParser
  attr_accessor :dbinfo
  def initialize(line)
    @line = line
    @scope = Id.new(1)                            # file scope
    @dbinfo = []
    @types = {}
  end

  def do_call(var, type, meta_id, loc_id, call=:declare)
    puts "  call void @llvm.dbg.#{call}(metadata #{type} #{var}, " +
         "metadata #{meta_id}, metadata !DIExpression()), !dbg #{loc_id}"
  end

  def type_id str
    return @types[str].id if @types.has_key?(str)
    t = str[-1] == '*' ? TDerived.new(type_id(str[0...-1])) : TBasic.new(str.to_sym)
    @types[str] = t
    return t.id
  end

  def parse(input)
    @line += 1
    input.chomp!
    
    if input.empty?
      puts input
    elsif input =~ /^\s*[;}]/                     # do nothing lines
      puts input
    elsif m = input.match(/define\s+(.+)\s+@([[:alnum:]_]+)(\([^\)]+\))/)
      f = Fun.new(m[2], @line)
      @dbinfo << f
      @scope = f.id
      puts "#{m[0]} #0 !dbg #{f.id} {"
    elsif m = input.match(/\s*([%_[:alnum:]]+)\s*=\s*alloca\s+(.+)\s*/)
      l = Loc.new(@line, @scope)
      t = type_id(m[2])
      v = Var.new(m[1].sub("%", ""), t, @line, @scope)
      @dbinfo << l << v
      @line += 1                                  # extra line for new call
      # puts "#{m[0]}, !dbg #{l.id}"
      puts input
      do_call(m[1], m[2] + "*", v.id, l.id)
    elsif input =~ /^\S/                          # non-body lines
      puts input
    else
      l = Loc.new(@line, @scope)
      @dbinfo << l
      puts "#{input}, !dbg #{l.id}"
    end
  end

  def print_dbinfo
    @dbinfo.each {|elem| puts elem }
    @types.values.each { |key| puts key }
  end
end

puts "source_filename = \"#{ARGF.filename}\""
p = LLParser.new(0)
ARGF.each { |line| p.parse(line) }

# Print debugging information
DDecls = DATA.read
printf DDecls, ARGF.filename, __dir__
p.print_dbinfo



__END__
; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.addr(metadata, metadata, metadata) #1
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "%s", directory: "%s")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
