source_filename = "simple.ll"
target triple = "x86_64-pc-linux-gnu"


define i64 @program(i64 %_argc3, { i64, [0 x i8*] }* %_argv1) !dbg !7 {
  %_argc4 = alloca i64
  %_argv2 = alloca { i64, [0 x i8*] }*
  call void @llvm.dbg.addr(metadata i64* %_argc4, metadata !14, metadata !DIExpression()), !dbg !16
  store i64 %_argc3, i64* %_argc4
  store { i64, [0 x i8*] }* %_argv1, { i64, [0 x i8*] }** %_argv2
  call void @llvm.dbg.addr(metadata {i64, [ 0 x i8* ] }** %_argv2, metadata !15, metadata !DIExpression()), !dbg !17

  ; argc = argc + 1
  %_argc5 = load i64, i64* %_argc4, !dbg !18
  %_bop6 = add i64 %_argc5, 1, !dbg !19
  store i64 %_bop6, i64* %_argc4, !dbg !20

  %_res = load i64, i64* %_argc4, !dbg !21
  ret i64 %_res, !dbg !22
}
; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.addr(metadata, metadata, metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "oat", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "simple.ll", directory: "/home/noah/projects/oatdb/tests")
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
!14 = !DILocalVariable(name: "argc", arg: 1, scope: !7, file: !1, line: 5, type: !10)
!15 = !DILocalVariable(name: "argv", arg: 2, scope: !7, file: !1, line: 5, type: !11)
!16 = !DILocation(line: 8, column: 8, scope: !7)
!17 = !DILocation(line: 9, column: 8, scope: !7)
!18 = !DILocation(line: 14, column: 9, scope: !7)
!19 = !DILocation(line: 15, column: 8, scope: !7)
!20 = !DILocation(line: 16, column: 8, scope: !7)
!21 = !DILocation(line: 18, column: 8, scope: !7)
!22 = !DILocation(line: 19, column: 8, scope: !7)
