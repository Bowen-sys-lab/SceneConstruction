# RGB 与红外预览

预览工具只显示 RGB 和 Thermal 两幅图，用于观察场景、材质、灯光和温度配置的效果。它不负责数据集采集或正式评测。

## 启动方式

默认项目环境为：

```text
Isaac Sim: D:\isaacsim\python.bat
项目根目录: D:\IsaacSim_Demo
```

如果环境不同，可以指定实际路径：

```powershell
.\tools\preview_rgb_thermal.ps1 `
  -SceneConfig .\configs\scene.yaml `
  -ProjectRoot D:\IsaacSim_Demo `
  -IsaacSimPython D:\isaacsim\python.bat
```

默认预览分辨率为 160×128。需要更清晰画面时，可以使用：

```powershell
.\tools\preview_rgb_thermal.ps1 `
  -SceneConfig .\configs\scene.yaml `
  -Width 320 -Height 256
```

## 观察内容

- RGB：贴图、颜色、灯光、可见目标和空间线索是否正常；
- Thermal：物体之间的温差、热点位置和夜间热对比是否符合场景设定。

调试信息不会覆盖在画面上。RGB 材质、红外材料、温度和灯光可以根据预览结果调整，修改后重新启动预览即可。

## 画面异常时

如果预览能够打开但画面效果不符合预期，可以依次检查：

1. Prim 路径；
2. 物体绑定；
3. 红外材料名称；
4. 温度差；
5. 显示温度范围；
6. RGB 贴图路径。
