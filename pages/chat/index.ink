<script def>
{
  "navigationBarTitleText": "问南财"
}
</script>

<script setup>
import wx from 'wx';
import { ask, isKeyConfigured } from '../../lib/deepseek.js';

export default {
  data: {
    question: '',
    reply: '',
    loading: false,
    error: '',
    keyMissing: false
  },
  onLoad() {
    this.setData({ keyMissing: !isKeyConfigured() });
  },
  onUnload() {
    // 页面销毁后放弃迟到的响应回调
    this._destroyed = true;
  },
  onQuestionInput(e) {
    this.setData({ question: e.detail.value });
  },
  // 镜腿触摸：keydown 直接提交（无返回/确认之分，响应最快）
  onKeyDown(event) {
    if (event.code === 'GlobalHook') {
      this.commitSend();
    }
  },
  // 确认键：keyup 提交并接管宿主默认行为
  onKeyUp(event) {
    if (event.code === 'Enter') {
      if (event.preventDefault) event.preventDefault();
      this.commitSend();
    }
  },
  // 发送按钮（bindtap 必须挂在 export default 顶层）
  send() {
    this.commitSend();
  },
  commitSend() {
    if (this.data.loading) return;
    const q = (this.data.question || '').trim();
    if (!q) {
      this.setData({ error: '请先输入问题' });
      return;
    }
    this.setData({ loading: true, error: '', reply: '' });
    ask(q)
      .then((content) => {
        if (this._destroyed) return;
        this.setData({ reply: content, loading: false });
      })
      .catch((err) => {
        if (this._destroyed) return;
        this.setData({
          error: err && err.message ? err.message : '请求失败',
          loading: false
        });
      });
  },
  goBack() {
    wx.navigateBack({ delta: 1 });
  }
}
</script>

<page>
  <view class="chat-page">
    <view class="topbar">
      <text class="title">问南财</text>
      <text class="back" bindtap="goBack">‹ 返回</text>
    </view>

    <view class="editor">
      <input
        class="question-input"
        value="{{question}}"
        placeholder="输入你的财经问题"
        bindinput="onQuestionInput"
        disabled="{{loading}}"
      />
      <button class="send-btn {{loading ? 'sending' : ''}}" bindtap="send">{{loading ? '…' : '发送'}}</button>
    </view>

    <scroll-view class="reply-area" scroll-y="true">
      <text ink:if="{{loading}}" class="loading">思考中…</text>
      <error-state ink:if="{{error}}" text="{{error}}" />
      <text ink:if="{{reply && !loading}}" class="reply">{{reply}}</text>
      <text ink:if="{{keyMissing && !loading && !error}}" class="key-missing">未配置 Key：打开 lib/config.js 填写 DEEPSEEK_API_KEY 后重新打包导入</text>
      <text ink:if="{{!reply && !loading && !error && !keyMissing}}" class="placeholder">提问后将显示 DeepSeek 的回答</text>
    </scroll-view>
  </view>
</page>

<style>
:root {
  --g: #40ff5e;
  --g72: rgba(64, 255, 94, 0.72);
  --g48: rgba(64, 255, 94, 0.48);
  --g24: rgba(64, 255, 94, 0.24);
  --g06: rgba(64, 255, 94, 0.06);
}
.chat-page {
  width: 448px;
  height: 328px;
  margin: 12px auto;
  display: flex;
  flex-direction: column;
  gap: 8px;
  font-family: sans-serif;
  color: var(--g72);
  box-sizing: border-box;
}
.topbar {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
}
.title {
  font-size: 16px;
  font-weight: 500;
  color: var(--g);
  letter-spacing: 0.02em;
}
.back {
  font-size: 12px;
  color: var(--g48);
}
.editor {
  display: flex;
  gap: 8px;
  align-items: stretch;
}
.question-input {
  flex: 1;
  min-height: 36px;
  padding: 8px 10px;
  font-size: 14px;
  color: var(--g72);
  background-color: var(--g06);
  border: 1px solid var(--g48);
  border-radius: 4px;
  box-sizing: border-box;
}
.send-btn {
  min-height: 36px;
  padding: 0 16px;
  font-size: 12px;
  font-weight: 500;
  color: var(--g72);
  background-color: transparent;
  border: 1px solid var(--g48);
  border-radius: 4px;
}
.send-btn.sending {
  color: var(--g48);
  border-color: var(--g24);
}
.reply-area {
  flex: 1;
  border-top: 1px solid var(--g24);
  padding-top: 8px;
  display: flex;
  flex-direction: column;
}
.loading {
  font-size: 14px;
  color: var(--g48);
}
.reply {
  font-size: 14px;
  line-height: 1.45;
  color: var(--g72);
  white-space: pre-wrap;
  word-break: break-word;
}
.key-missing {
  font-size: 12px;
  line-height: 1.4;
  color: var(--g48);
}
.placeholder {
  font-size: 12px;
  color: var(--g48);
}
@media (target: _current) {
  .chat-page {
    width: 416px;
    height: 126px;
    margin: 12px auto;
  }
  .reply-area {
    min-height: 40px;
  }
  .reply {
    font-size: 12px;
  }
}
@media (target: _blank) {
  .chat-page {
    width: 448px;
    height: 328px;
  }
}
</style>
