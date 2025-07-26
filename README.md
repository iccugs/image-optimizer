# Image Optimizer GUI

A simple GUI frontend for **pngquant** and **oxipng** that provides maximum PNG compression with minimal quality loss. This tool combines both compression utilities to achieve optimal file size reduction for your PNG images.

## 🚀 Features

- **Dual Compression**: Utilizes both pngquant and oxipng for maximum file size reduction
- **Drag & Drop Interface**: Simple GUI - just drag your PNG files and click start
- **In-Place Compression**: Overwrites original files with compressed versions
- **Cross-PowerShell Support**: Works with both PowerShell 7 and PowerShell 5
- **Batch Processing**: Handle multiple PNG files at once

## 📋 Requirements

- **Windows 11** (currently only supported OS)
- **pngquant** - compiled and added to your PATH environment variable
- **oxipng** - compiled and added to your PATH environment variable
- **PowerShell** (5 or 7)

## 🛠️ Installation

### 1. Install Dependencies

You need to compile and install both compression tools:

- **oxipng**: [https://github.com/oxipng/oxipng](https://github.com/oxipng/oxipng)
- **pngquant**: [https://github.com/kornelski/pngquant](https://github.com/kornelski/pngquant)

Make sure both executables are in your system's PATH environment variable.

### 2. Download This Tool

Clone or download this repository to your local machine.

## 🎯 Usage

1. **Double-click** the batch file (`.bat`) to launch the application
2. The batch file will automatically:
   - Look for PowerShell 7 first
   - Fall back to PowerShell 5 if PowerShell 7 isn't found
   - Open the PowerShell GUI script
3. **Drag and drop** your PNG files into the GUI window
4. **Click "Start"** to begin compression
5. Wait for the process to complete

## ⚠️ Important Notes

- **Backup Your Files**: The tool overwrites original files in-place. Make backups if you want to preserve the originals
- **PNG Only**: Currently only supports PNG files out of the box
- **File Overwriting**: Compressed images replace the original files at their current location

## 🔧 Customization

The script can be easily modified to:
- Accept other image file types
- Adjust compression settings
- Change output behavior
- Modify compression parameters

## 🏗️ How It Works

1. **pngquant** performs lossy compression by reducing the color palette
2. **oxipng** performs lossless optimization of the PNG structure
3. Both tools work together to achieve maximum file size reduction while maintaining visual quality

## 📊 Use Case

This tool was created to quickly compress screenshots for web upload, reducing file sizes significantly while maintaining acceptable image quality for web display.

## 🤝 Contributing

This was a quick afternoon project, but if there's interest in improvements:
- ⭐ **Star this repository** to show support
- 🐛 **Report issues** if you encounter problems
- 💡 **Suggest features** for future updates

## 📝 License

[Add your preferred license here]

## 🙏 Acknowledgments

- [oxipng](https://github.com/oxipng/oxipng) - Lossless PNG optimizer
- [pngquant](https://github.com/kornelski/pngquant) - Lossy PNG compressor

---

*Made quickly in an afternoon to solve a simple problem. Sometimes the best tools are the simple ones!*
