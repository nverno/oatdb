source_filename = "step-ir.ll"
target triple = "x86_64-pc-linux-gnu"

define i64 @program() !dbg !7 {
  %1 = alloca i64
  store i64 10, i64* %1
  call void @llvm.dbg.addr(metadata i64* %1, metadata !11, metadata !DIExpression()), !dbg !12
  %2 = load i64, i64* %1, !dbg !13
  ret i64 %2, !dbg !14
}

declare void @llvm.dbg.addr(metadata, metadata, metadata)

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "oat", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "step-ir.ll", directory: "/home/noah/projects/oatdb/tests")

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}

!7 = distinct !DISubprogram(name: "program", scope: !1, file: !1, line: 4, type: !8, isLocal: false, isDefinition: true, scopeLine: 1, flags: DIFlagPrototyped, isOptimized: false, unit: !0)
!8 = !DISubroutineType(types: !9)
!9 = !{!10}
!10 = !DIBasicType(name: "int", size: 64, encoding: DW_ATE_signed)

!11 = !DILocalVariable(name: "%1", scope: !7, file: !1, line: 6, type: !10)
!12 = !DILocation(line: 7, column: 4, scope: !7)
!13 = !DILocation(line: 8, column: 4, scope: !7)
!14 = !DILocation(line: 9, column: 4, scope: !7)
