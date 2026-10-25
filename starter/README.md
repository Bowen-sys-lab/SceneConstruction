# 新场景起始配置

`configs/` 中的三个文件提供一个新场景的配置起点。复制后修改场景路径、Prim 路径、红外材料和温度即可。

建议目录：

```text
new_scene/
├─ scene.usda
├─ configs/
│  ├─ scene.yaml
│  ├─ thermal.yaml
│  └─ display.yaml
├─ textures/
└─ materials/
```

复制完成后可先运行 `tools/check_package.ps1`，再运行 `tools/preview_rgb_thermal.ps1`。
