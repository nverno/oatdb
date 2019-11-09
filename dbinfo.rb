#!/usr/bin/env ruby
# frozen_string_literal: true

class Id
  @@count = 6                                         # 1st 6 used in DATA
  def initialize
    @@count += 1
    @n = @@count
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
  def initialize(line, name)
    super()
    @line, @name = line, name
  end
  def to_s
    "#{@id} = distinct !DISubprogram(name: \"#{@name}\", line #{@line}, " +
      "scope: !1, file: !1, isLocal: false, isDefinition: true, " +
      "scopeLine: #{@line}, isOptimized: false, " +
      "flags: DIFlagPrototyped, unit: !0, variables: !2)"
  end
end

class TBasic < DBInfo
  KINDS = {
    :I64 => "name: \"int\", size 64, encoding: DW_ATE_signed",
    :I1 => "name: \"bool\", size 1, encoding: DW_ATE_boolean",
    :I8 => "name: \"char\", size 8, encoding: DW_ATE_signed_char"
  }
  def initialize(kind)
    super()
    @desc = KINDS[kind]
  end
  def to_s; "#{@id} = !DIBasicType(#{@desc})" end
end

class TDerived < DBInfo
  def initialize(base, tag=:DW_TAG_pointer_type, size=64)
    @base, @tag, @size = base, tag, size
  end
  def to_s
    "#{@id} = !DIDerivedType(tag: #{@tag}, size: #{@size}, baseType: #{@base})"
  end
end

class Var < DBInfo
  def initialize(name, type, line, scope, arg=1)
    @name, @type, @line, @scope, @arg = name, type, line, scope, arg
  end
  def to_s
    "#{@id} = !DILocalVariable(name: \"#{@name}\", type: #{@type}, " +
      "scope: #{@scope}, file: !1, line: #{@line}, arg: #{@arg})"
  end
end

# call void @llvm.dbg.addr(metadata i32* %4, metadata !14, metadata !DIExpression()), !dbg !15
class DbgCall < DBInfo
  def initialize(var, meta_id, call=:declare)
    @var, @meta_id = var, meta_id
  end
  def to_s
    "call void @llvm.dbg.addr(metadata i32* %4, metadata !14, metadata !DIExpression()), !dbg !15"

  end
end


ncalls = 0
ARGF.each_with_index do |line, idx|
  
  print ARGF.filename, ":", idx, ";", line
end

# Print debugging information
DDecls = DATA.read
printf DDecls, ARGF.filename, __dir__


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
