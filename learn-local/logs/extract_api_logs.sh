#!/bin/bash

if [ $# -ne 1 ]; then
    echo "用法：$0 日志文件路径"
    exit 1
fi

logfile="$1"

# 核心提取逻辑，完美适配你的日志格式：API Request : { / API Response: {
awk '
# 匹配 API Request（兼容冒号前后空格）
/\[DEBUG\] API Request *: *\{/ {
    in_request = 1;
    brace = 1;  # 起始行的 { 计数+1
    req = $0 "\n";
    next;
}

# 匹配 API Response（兼容冒号前后空格，适配你日志的 Response: { 格式）
/\[DEBUG\] API Response *: *\{/ {
    in_response = 1;
    brace = 1;
    resp = $0 "\n";
    next;
}

# 提取 Request 内容，处理嵌套大括号
in_request {
    req = req $0 "\n";
    brace += gsub(/{/, "{");  # 统计新增 {
    brace -= gsub(/}/, "}");  # 统计新增 }
    if (brace == 0) {         # 大括号完全闭合，结束提取
        in_request = 0;
        requests[++req_count] = req;
    }
    next;
}

# 提取 Response 内容，处理嵌套大括号
in_response {
    resp = resp $0 "\n";
    brace += gsub(/{/, "{");
    brace -= gsub(/}/, "}");
    if (brace == 0) {
        in_response = 0;
        responses[++resp_count] = resp;
    }
    next;
}

# 成对输出 Request 和 Response
END {
    print "✅ 提取完成！共找到 " req_count " 对 API 请求/响应"
    print "================================================"
    print ""
    for (i=1; i<=req_count && i<=resp_count; i++) {
        print "===== 📥 API Request " i " ====="
        print requests[i];
        print "===== 📤 API Response " i " ====="
        print responses[i];
        print "=================================================="
        print "";
    }
}
' "$logfile"
