// RUN: %target-swift-frontend -parse-as-library -O -target-cpu core2 -emit-ir  %s | %FileCheck %s
// REQUIRES: swift_stdlib_no_asserts,optimized_stdlib,CPU=x86_64

// This is an end-to-end test to ensure that the optimizer generates
// a simple literal for character literals.

// Please note: this test targets "core2" to ensure consistent output
// on all x86 host processors.

// CHECK-LABEL: define {{.*}}charArray
// CHECK:  store i64 97
// CHECK:  store i64 98
// CHECK:  store i64 99
// CHECK:  store i64 100
// CHECK:  ret
public func charArray(_ i: Int) -> [Character] {
  return [ "a", "b", "c", "d" ]
}

// NOTE: 97 = 'a'
// NOTE: -2233785415175766016 = 0xE1 = 0xE0 (ASCII discrim) | 0x01 (count)
//
// CHECK-LABEL: define {{.*}}singleChar
// CHECK-NEXT: ret { i64, %swift.bridge* } { i64 97, %swift.bridge* inttoptr (i64 -2233785415175766016 to %swift.bridge*) }
public func singleChar() -> Character {
  return "a"
}

// NOTE: 10852326 = 0xE6 0x97 0xA5 (little endian), the encoding of U+65E5
// NOTE: -6701356245527298048 = 0xA3 = 0xA0 (non-ASCII discrim) | 0x03 (count)
//
// CHECK-LABEL: define {{.*}}singleNonAsciiChar
// CHECK-NEXT: ret { i64, %swift.bridge* } { i64 10852326, %swift.bridge* inttoptr (i64 -6701356245527298048 to %swift.bridge*) }
public func singleNonAsciiChar() -> Character {
  return "日"
}

// NOTE: -9223372036854775808 = 0x80 = immortal large discrim
// NOTE: 25 = length in UTF-8 code units
//
// CHECK-LABEL: define {{.*}}singleNonSmolChar
// CHECK:   ret { i64, %swift.bridge* } { i64 25, %swift.bridge* {{.*}}@0{{.*}}i64 -9223372036854775808
public func singleNonSmolChar() -> Character {
  return "👩‍👩‍👦‍👦"
}

