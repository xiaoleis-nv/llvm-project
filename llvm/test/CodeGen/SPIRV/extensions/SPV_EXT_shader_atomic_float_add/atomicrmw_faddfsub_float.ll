; RUN: not llc -O0 -mtriple=spirv32-unknown-unknown %s -o %t.spvt 2>&1 | FileCheck %s --check-prefix=CHECK-ERROR

; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv32-unknown-unknown --spirv-ext=+SPV_EXT_shader_atomic_float_add %s -o - | FileCheck %s

; CHECK-ERROR: LLVM ERROR: The atomic float instruction requires the following SPIR-V extension: SPV_EXT_shader_atomic_float_add

; CHECK: Capability AtomicFloat32AddEXT
; CHECK: Extension "SPV_EXT_shader_atomic_float_add"
; CHECK-DAG: %[[TyFP32:[0-9]+]] = OpTypeFloat 32
; CHECK-DAG: %[[TyInt32:[0-9]+]] = OpTypeInt 32 0
; CHECK-DAG: %[[Const0:[0-9]+]] = OpConstant %[[TyFP32]] 0
; CHECK-DAG: %[[Const42:[0-9]+]] = OpConstant %[[TyFP32]] 42
; CHECK-DAG: %[[ScopeDevice:[0-9]+]] = OpConstant %[[TyInt32]] 1
; CHECK-DAG: %[[ScopeWorkgroup:[0-9]+]] = OpConstant %[[TyInt32]] 2
; CHECK-DAG: %[[MemSeqCst:[0-9]+]] = OpConstant %[[TyInt32]] 16
; CHECK-DAG: %[[WorkgroupMemory:[0-9]+]] = OpConstant %[[TyInt32]] 512
; CHECK-DAG: %[[TyFP32Ptr:[0-9]+]] = OpTypePointer {{[a-zA-Z]+}} %[[TyFP32]]
; CHECK-DAG: %[[DblPtr:[0-9]+]] = OpVariable %[[TyFP32Ptr]] {{[a-zA-Z]+}} %[[Const0]]
; CHECK: OpAtomicFAddEXT %[[TyFP32]] %[[DblPtr]] %[[ScopeDevice]] %[[MemSeqCst]] %[[Const42]]
; CHECK: %[[Const42Neg:[0-9]+]] = OpFNegate %[[TyFP32]] %[[Const42]]
; CHECK: OpAtomicFAddEXT %[[TyFP32]] %[[DblPtr]] %[[ScopeDevice]] %[[MemSeqCst]] %[[Const42Neg]]
; CHECK: OpAtomicFAddEXT %[[TyFP32]] %[[DblPtr]] %[[ScopeDevice]] %[[MemSeqCst]] %[[Const42]]
; CHECK: OpAtomicFAddEXT %[[TyFP32]] %[[DblPtr]] %[[ScopeWorkgroup]] %[[WorkgroupMemory]] %[[Const42]]
; CHECK: %[[Neg42:[0-9]+]] = OpFNegate %[[TyFP32]] %[[Const42]]
; CHECK: OpAtomicFAddEXT %[[TyFP32]] %[[DblPtr]] %[[ScopeWorkgroup]] %[[WorkgroupMemory]] %[[Neg42]]

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64"

@f = common dso_local local_unnamed_addr addrspace(1) global float 0.000000e+00, align 8

define dso_local spir_func void @test1() local_unnamed_addr {
entry:
  %addval = atomicrmw fadd ptr addrspace(1) @f, float 42.000000e+00 seq_cst
  %subval = atomicrmw fsub ptr addrspace(1) @f, float 42.000000e+00 seq_cst
  ret void
}

define dso_local spir_func void @test2() local_unnamed_addr {
entry:
  %addval = tail call spir_func float @_Z21__spirv_AtomicFAddEXT(ptr addrspace(1) @f, i32 1, i32 16, float 42.000000e+00)
  ret void
}

declare dso_local spir_func float @_Z21__spirv_AtomicFAddEXT(ptr addrspace(1), i32, i32, float)

define dso_local spir_func void @test3() local_unnamed_addr {
entry:
  %r1 = tail call spir_func float @_Z25atomic_fetch_add_explicitPU3AS1VU7_Atomicff12memory_order(ptr addrspace(1) @f, float 42.000000e+00, i32 0)
  %r2 = tail call spir_func float @_Z25atomic_fetch_sub_explicitPU3AS1VU7_Atomicff12memory_order(ptr addrspace(1) @f, float 42.000000e+00, i32 0)
  ret void
}

declare spir_func float @_Z25atomic_fetch_add_explicitPU3AS1VU7_Atomicff12memory_order(ptr addrspace(1), float, i32)
declare spir_func float @_Z25atomic_fetch_sub_explicitPU3AS1VU7_Atomicff12memory_order(ptr addrspace(1), float, i32)

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"wchar_size", i32 4}
