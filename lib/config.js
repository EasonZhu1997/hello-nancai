// ====== DeepSeek 配置 ======
// 1. 到 https://platform.deepseek.com 申请 API Key
// 2. 把 Key 填到下面 DEEPSEEK_API_KEY 的引号内，保存后重新打包导入模拟器
// 注意：Key 会随 AIX 包一起分发，请勿把填好 Key 的包发给不可信的第三方

export const DEEPSEEK_API_KEY = ''; // <-- 在这里填写你的 DeepSeek API Key

export const DEEPSEEK_BASE_URL = 'https://api.deepseek.com';
export const DEEPSEEK_MODEL = 'deepseek-chat'; // 也可换 'deepseek-reasoner'

export const SYSTEM_PROMPT =
  '你是「南财」，一个简洁专业的财经助手。回答控制在 150 字以内，' +
  '要点优先，涉及行情与数据时提示信息可能滞后，不构成投资建议。';
