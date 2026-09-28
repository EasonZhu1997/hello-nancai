# Agent Manifest

## Identity
- **Name**: hello 南财
- **Version**: 1.0.0
- **Description**: 问候 + 财经问答智能体：展示 "hello 南财"，并接入 DeepSeek（deepseek-chat）提供财经问答。联网经 wx.request 调用 DeepSeek API，Key 配置于 lib/config.js。
- **Author**: WorkBuddy

## Capabilities
- **Permissions**:
  - (无 — 纯展示，无需硬件或网络权限)
- **Skills**:
  - greeting
  - finance-qa (DeepSeek)
