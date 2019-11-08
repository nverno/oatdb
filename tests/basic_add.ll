; generated from: tests/basic_add.oat
source_filename = "basic_add.oat"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

define i64 @program(i64 %_argc3, { i64, [0 x i8*] }* %_argv1) #0 !dbg !7 {
  %_argc4 = alloca i64
  %_argv2 = alloca { i64, [0 x i8*] }*
  store i64 %_argc3, i64* %_argc4
  store { i64, [0 x i8*] }* %_argv1, { i64, [0 x i8*] }** %_argv2
  call void @llvm.dbg.addr(metadata i64* %_argc4, metadata !14, metadata !DIExpression()), !dbg !15
  call void @llvm.dbg.addr(metadata {i64, [ 0 x i8* ] }** %_argv2, metadata !16, metadata !DIExpression()), !dbg !15

  ; argc = argc + 1
  %_argc5 = load i64, i64* %_argc4, !dbg !17
  %_bop6 = add i64 %_argc5, 1, !dbg !18
  store i64 %_bop6, i64* %_argc4, !dbg !19

  %_res = load i64, i64* %_argc4, !dbg !20
  ret i64 %_res, !dbg !21
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.addr(metadata, metadata, metadata) #1
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "basic_add.oat", directory: "/home/noah/projects/oatdb/tests")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!7 = distinct !DISubprogram(name: "program", scope: !1, file: !1, line: 1, type: !8, isLocal: false, isDefinition: true, scopeLine: 1, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !10, !11}
!10 = !DIBasicType(name: "int", size: 64, encoding: DW_ATE_signed)
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!13 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!14 = !DILocalVariable(name: "argc", arg: 1, scope: !7, file: !1, line: 1, type: !10)
!15 = !DILocation(line: 1, column: 14, scope: !7)
!16 = !DILocalVariable(name: "argv", arg: 2, scope: !7, file: !1, line: 1, type: !11)

!17 = !DILocation(line: 3, column: 6, scope: !7)
!18 = !DILocation(line: 3, column: 13, scope: !7)
!19 = !DILocation(line: 3, column: 18, scope: !7)

!20 = !DILocation(line: 5, column: 6, scope: !7)
!21 = !DILocation(line: 5, column: 6, scope: !7)


declare i64* @oat_malloc(i64)
declare i64* @oat_alloc_array(i64)
declare void @oat_assert_not_null(i8*)
declare void @oat_assert_array_length(i64*, i64)
declare { i64, [0 x i64] }* @array_of_string(i8*)
declare i8* @string_of_array({ i64, [0 x i64] }*)
declare i64 @length_of_string(i8*)
declare i8* @string_of_int(i64)
declare i8* @string_cat(i8*, i8*)
declare void @print_string(i8*)
declare void @print_int(i64)
declare void @print_bool(i1)
