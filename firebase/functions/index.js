// v1 / 1st Gen 写法
const functions = require('firebase-functions/v1');      // ← 注意是 v1 根包
const admin = require('firebase-admin');
admin.initializeApp();

// Auth 删除触发器：与你日志里的 onUserDeleted 对应
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  console.log('User deleted:', user.uid);
  // TODO: 在这里清理用户数据
});

// 如果你有 Express 路由（api_manager.js），继续这样导出 HTTP 函数
// const app = require('./api_manager');
// exports.api = functions.https.onRequest(app);
