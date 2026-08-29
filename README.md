# Alipay AI Payment Agent Skill
+

## 项目事实速览

面向 Codex Agent 的支付宝开放平台 RSA2 配置与验收工作流 Skill。

**运行与开发**：复制 Skill 目录到 `${CODEX_HOME:-$HOME/.codex}/skills/`，再运行校验脚本。

**边界与安全**：模型、第三方 API、支付渠道、桌面自动化、OCR 和外部数据源均受其自身授权、限额和兼容性约束；不要把演示数据或测试通过当作生产 SLA。禁止提交密钥、令牌、个人数据、模型文件和生产日志。许可证以仓库 LICENSE/NOTICE 及第三方组件声明为准。


面向 Codex Agent 的支付宝开放平台 RSA2 直连支付配置 Skill，适用于 SynthApi / new-api 及具有相同订单模型的服务端项目。

它把支付宝应用准备、密钥角色、回调安全、主动查单、幂等入账、沙箱验收、生产切换和故障排查整理为可重复执行的 Agent 工作流。仓库只包含教程、占位配置和不会回显凭据的结构校验脚本。

## Capabilities

- 配置 `alipay.trade.page.pay` 页面支付与 `alipay.trade.query` 主动查单。
- 区分应用私钥、应用公钥和支付宝平台公钥，避免常见密钥误用。
- 校验 AppID、SellerID、RSA PEM、HTTPS 回调地址和最低充值金额。
- 指导异步通知验签、金额核对、商户核对和事务级幂等入账。
- 覆盖充值、订阅、浏览器同步返回、补偿查单和退款人工复核。
- 提供 Cloudflare、Nginx、证书、沙箱与生产环境的排障清单。

## Repository Layout

```text
configure-alipay-ai-payment/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── alipay-open-platform.md
│   ├── callback-security.md
│   ├── synthapi-configuration.md
│   └── troubleshooting.md
└── scripts/
    └── validate-alipay-config.sh
```

## Install

```bash
cp -R configure-alipay-ai-payment "${CODEX_HOME:-$HOME/.codex}/skills/"
```

安装后可直接调用：

```text
Use $configure-alipay-ai-payment to configure Alipay RSA2 direct payment for my SynthApi deployment.
```

## Configuration Validation

创建一个仅用于本机检查的 `KEY=VALUE` 文件：

```dotenv
ALIPAY_ENABLED=false
ALIPAY_APP_ID=2026000000000001
ALIPAY_SELLER_ID=2088000000000001
ALIPAY_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----REPLACE-----END PRIVATE KEY-----
ALIPAY_PLATFORM_PUBLIC_KEY=-----BEGIN PUBLIC KEY-----REPLACE-----END PUBLIC KEY-----
ALIPAY_NOTIFY_URL=https://pay.example.com/api/alipay/notify
ALIPAY_RETURN_URL=https://pay.example.com/api/alipay/return
ALIPAY_MIN_TOPUP=0.01
```

执行：

```bash
configure-alipay-ai-payment/scripts/validate-alipay-config.sh ./alipay.local.env
```

脚本只输出字段名和检查结果，不输出字段值。结构校验无法替代支付宝开放平台的产品授权检查，也不能证明私钥与平台中上传的应用公钥匹配。

## Skill Validation

使用 Codex 自带 `skill-creator` 验证目录规范：

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" \
  configure-alipay-ai-payment
```

## Production Checklist

1. 在支付宝开放平台完成应用和支付产品授权。
2. 在受控环境生成至少 2048 位 RSA 密钥，只上传应用公钥。
3. 配置公网 HTTPS `notify_url` 与 `return_url`，回调路径不得启用浏览器挑战。
4. 先以禁用状态保存沙箱配置并完成小额测试。
5. 验证成功通知、重复通知、主动查单、关闭订单和浏览器中断场景。
6. 确认订单状态迁移和额度入账位于同一事务且只能执行一次。
7. 生产启用后保留订单号、支付宝交易号和脱敏审计记录。

## Security Boundary

禁止提交或传播以下内容：

- 应用私钥、SSH 私钥、数据库密码和管理员会话。
- 真实商户的完整 AppID/SellerID 组合。
- 完整生产回调正文、签名或含用户隐私的支付日志。
- 通过个人收款监听、短信转发或未授权插件绕过支付宝产品授权的实现。

同步浏览器返回只能用于展示状态，不能作为入账依据。入账必须来自已验签通知或经过支付宝平台验证的主动查单结果。

## Scope

本 Skill 聚焦支付宝官方 RSA2 页面支付与主动查单，不包含个人收款码监听、SMS Forwarder、聚合支付私有插件或支付页面视觉设计。

## License

MIT。支付宝相关名称和接口归其权利人所有，使用者需遵守支付宝开放平台协议及所在地法律法规。
