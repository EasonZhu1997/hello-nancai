// DeepSeek Chat API 封装（OpenAI 兼容协议，经 wx.request 调用）。
// 仅使用 apis-wx.md 中确认过的 wx.request 契约：
// - 默认 responseType 是 arraybuffer，必须显式设 text + dataType 'json'
// - success(res) 收到 { data, statusCode, header, errMsg }；fail(err) 收到 { errMsg }
import wx from 'wx';
import {
  DEEPSEEK_API_KEY,
  DEEPSEEK_BASE_URL,
  DEEPSEEK_MODEL,
  SYSTEM_PROMPT
} from './config.js';

// Key 是否已填写（用于页面上的显式提示，而不是静默失败）
export function isKeyConfigured() {
  return (
    typeof DEEPSEEK_API_KEY === 'string' && DEEPSEEK_API_KEY.trim().length > 0
  );
}

// messages: [{ role: 'user' | 'assistant', content: string }, ...]
// 返回 Promise<string>（助手回复文本）
export function chat(messages) {
  return new Promise((resolve, reject) => {
    if (!isKeyConfigured()) {
      reject(
        new Error('未配置 DeepSeek API Key，请在 lib/config.js 中填写 DEEPSEEK_API_KEY')
      );
      return;
    }
    wx.request({
      url: DEEPSEEK_BASE_URL + '/chat/completions',
      method: 'POST',
      header: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + DEEPSEEK_API_KEY
      },
      data: {
        model: DEEPSEEK_MODEL,
        messages: [{ role: 'system', content: SYSTEM_PROMPT }].concat(messages),
        stream: false
      },
      // 关键：默认 responseType 是 arraybuffer，必须显式声明为 text
      responseType: 'text',
      dataType: 'json',
      timeout: 60000,
      success(res) {
        let payload = res.data;
        // dataType: 'json' 解析失败时会拿到原始文本，这里兜底手动解析
        if (typeof payload === 'string') {
          try {
            payload = JSON.parse(payload);
          } catch (e) {
            reject(new Error('响应解析失败（HTTP ' + res.statusCode + '）'));
            return;
          }
        }
        if (res.statusCode !== 200) {
          const detail =
            payload && payload.error && payload.error.message
              ? payload.error.message
              : 'HTTP ' + res.statusCode;
          reject(new Error('DeepSeek 请求失败：' + detail));
          return;
        }
        const content =
          payload &&
          payload.choices &&
          payload.choices[0] &&
          payload.choices[0].message &&
          payload.choices[0].message.content;
        if (typeof content !== 'string' || content.length === 0) {
          reject(new Error('DeepSeek 返回格式异常'));
          return;
        }
        resolve(content);
      },
      fail(err) {
        reject(
          new Error(
            '网络请求失败：' + (err && err.errMsg ? err.errMsg : '未知错误')
          )
        );
      }
    });
  });
}

// 便捷方法：单轮提问
export function ask(question) {
  return chat([{ role: 'user', content: String(question) }]);
}
