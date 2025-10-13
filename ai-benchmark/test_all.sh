#!/bin/bash
# Yaklang AI Benchmark - 自动测试脚本
# 运行所有题目并生成测试报告

echo "==================================="
echo " Yaklang AI Benchmark Test Suite"
echo "==================================="
echo ""

# 统计变量
total_tests=0
passed_tests=0
failed_tests=0
failed_files=()

# 测试单个文件的函数
test_file() {
    local file=$1
    local level=$2
    
    echo -n "Testing $file ... "
    
    if yak "$file" > /dev/null 2>&1; then
        echo "✓ PASS"
        ((passed_tests++))
    else
        echo "✗ FAIL"
        ((failed_tests++))
        failed_files+=("$file")
    fi
    
    ((total_tests++))
}

# 测试 Level 1
echo "📗 Testing Level 1 (Basic)"
echo "-----------------------------------"
for file in PRACTICE_level1_*.yak; do
    if [ -f "$file" ]; then
        test_file "$file" "Level 1"
    fi
done
echo ""

# 测试 Level 2
echo "📘 Testing Level 2 (Intermediate)"
echo "-----------------------------------"
for file in PRACTICE_level2_*.yak; do
    if [ -f "$file" ]; then
        test_file "$file" "Level 2"
    fi
done
echo ""

# 测试 Level 3
echo "📕 Testing Level 3 (Advanced)"
echo "-----------------------------------"
for file in PRACTICE_level3_*.yak; do
    if [ -f "$file" ]; then
        test_file "$file" "Level 3"
    fi
done
echo ""

# 打印总结
echo "==================================="
echo " Test Summary"
echo "==================================="
echo "Total tests: $total_tests"
echo "Passed: $passed_tests ($(awk "BEGIN {printf \"%.2f\", ($passed_tests/$total_tests)*100}")%)"
echo "Failed: $failed_tests ($(awk "BEGIN {printf \"%.2f\", ($failed_tests/$total_tests)*100}")%)"
echo ""

# 如果有失败的测试，列出来
if [ $failed_tests -gt 0 ]; then
    echo "❌ Failed tests:"
    for file in "${failed_files[@]}"; do
        echo "  - $file"
    done
    echo ""
    exit 1
else
    echo "✅ All tests passed!"
    echo ""
    exit 0
fi

