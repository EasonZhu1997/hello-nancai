<script def>
{
  "navigationBarTitleText": "hello 南财"
}
</script>

<script setup>
import wx from 'wx';

export default {
  data: {
    greeting: 'hello 南财',
    subtitle: '欢迎使用本智能体',
    isChinese: false,
    pressed: false
  },
  onLoad() {
    console.log('Page loaded: hello 南财');
  },
  onUnload() {
    if (this._pressedTimer) {
      clearTimeout(this._pressedTimer);
      this._pressedTimer = null;
    }
  },
  // 按下：只做即时反馈，不在这里提交动作（宿主默认行为在 keyup 之后才跑）
  onKeyDown(event) {
    const code = event.code;
    if (code === 'Enter' || code === 'GlobalHook') {
      this.setData({ pressed: true });
      // 兜底：个别宿主只在 keydown 上报 GlobalHook、没有对应 keyup，
      // 用有界定时器保证按压态一定会被释放
      if (this._pressedTimer) clearTimeout(this._pressedTimer);
      this._pressedTimer = setTimeout(() => {
        if (this.data.pressed) this.setData({ pressed: false });
      }, 400);
    }
    if (code === 'GlobalHook') {
      // 镜腿没有返回/确认之分，keydown 直接提交可拿到最快响应；
      // 若宿主同时上报 keyup，由 commitToggle 的 350ms 去重兜底
      this.commitToggle();
    }
  },
  onKeyUp(event) {
    const code = event.code;
    if (code === 'Enter') {
      // 接管宿主默认确认行为（进入导航模式/激活目标）
      if (event.preventDefault) event.preventDefault();
      this.commitToggle();
    } else if (code === 'GlobalHook') {
      // 镜腿触摸：不同宿主可能在 keydown 或 keyup 上报，这里在 keyup 提交
      this.commitToggle();
    }
    if (code === 'ArrowUp' || code === 'ArrowDown') {
      if (event.preventDefault) event.preventDefault();
    }
    if (this.data.pressed) {
      this.setData({ pressed: false });
    }
  },
  // 模拟器 / 触屏直接点击按钮：bindtap 处理器必须挂在 export default 顶层
  toggleGreeting() {
    this.commitToggle();
  },
  // 进入 DeepSeek 问答页
  goChat() {
    wx.navigateTo({ url: 'pages/chat/index' });
  },
  commitToggle() {
    // 同一次物理按压可能同时上报 GlobalHook 与 Enter，用时间窗去重
    const now = Date.now();
    if (this._lastToggleAt && now - this._lastToggleAt < 350) return;
    this._lastToggleAt = now;
    const isChinese = !this.data.isChinese;
    this.setData({
      isChinese,
      greeting: isChinese ? '你好南财' : 'hello 南财'
    });
  }
}
</script>

<page>
  <view class="container">
    <view class="card">
      <text class="title">{{ greeting }}</text>
      <text class="subtitle">{{ subtitle }}</text>
      <button class="toggle-btn {{pressed ? 'toggle-btn-active' : ''}}" bindtap="toggleGreeting">{{ isChinese ? '切换为英文' : '切换为中文' }}</button>
      <button class="chat-btn" bindtap="goChat">问南财 · DeepSeek ›</button>
    </view>
  </view>
</page>

<style>
.container {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 480px;
  height: 352px;
  background-color: var(--color-background, #000000);
}

.card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-md, 12px);
  width: 448px;
  padding: var(--spacing-lg, 24px);
  background-color: var(--color-surface, #0a0a0a);
  border: var(--border-width-default, 2px) solid var(--border-color-default, rgba(64, 255, 94, 0.6));
  border-radius: var(--radius-md, 12px);
}

.title {
  font-size: 32px;
  font-weight: 700;
  color: var(--color-text-primary, #ffffff);
}

.subtitle {
  font-size: 16px;
  color: var(--color-text-secondary, rgba(255, 255, 255, 0.7));
}

.toggle-btn {
  margin-top: var(--spacing-sm, 8px);
  padding: 10px 20px;
  font-size: 16px;
  color: #ffffff;
  background-color: rgba(64, 255, 94, 0.15);
  border: 2px solid rgba(64, 255, 94, 0.6);
  border-radius: 8px;
}

.toggle-btn-active {
  background-color: rgba(64, 255, 94, 0.3);
  border-color: rgba(64, 255, 94, 1);
}

.chat-btn {
  margin-top: 4px;
  padding: 8px 16px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.7);
  background-color: transparent;
  border: 1px solid rgba(64, 255, 94, 0.4);
  border-radius: 8px;
}

@media (target: _current) {
  .container {
    width: 448px;
    height: 150px;
  }
}

@media (target: _blank) {
  .container {
    width: 480px;
    height: 352px;
  }
}
</style>
