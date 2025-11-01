import tkinter as tk
import os

class OBSWarningDialog:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("OBS Recording Alert")
        self.root.geometry("480x240")
        self.root.resizable(False, False)
        self.root.overrideredirect(True)
        self.root.configure(bg='#ff6b35')
        self.root.attributes('-topmost', True)
        
        # Center window
        self.root.update_idletasks()
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()
        x = (screen_width - 480) // 2
        y = (screen_height - 240) // 2
        self.root.geometry(f"480x240+{x}+{y}")
        
        self.setup_ui()
    
    def setup_ui(self):
        # Border
        border = tk.Frame(self.root, bg='#ff6b35')
        border.pack(fill='both', expand=True, padx=2, pady=2)
        
        # Main container
        main = tk.Frame(border, bg='#2d2d30')
        main.pack(fill='both', expand=True)
        
        # Title bar
        title_bar = tk.Frame(main, bg='#ff6b35', height=45)
        title_bar.pack(fill='x')
        title_bar.pack_propagate(False)
        
        tk.Label(title_bar, text="⚠ OBS Recording Issue Detected", 
                bg='#ff6b35', fg='#ffffff', 
                font=('Segoe UI', 12, 'bold')).pack(side='left', padx=15)
        
        close = tk.Label(title_bar, text="×", bg='#ff6b35', fg='#ffffff', 
                        font=('Segoe UI', 18, 'bold'), cursor='hand2')
        close.pack(side='right', padx=15)
        close.bind('<Button-1>', lambda e: self.root.destroy())
        
        # Make draggable
        title_bar.bind('<Button-1>', self.start_move)
        title_bar.bind('<B1-Motion>', self.on_move)
        
        # Content
        content = tk.Frame(main, bg='#1e1e1e')
        content.pack(fill='both', expand=True, padx=12, pady=12)
        
        tk.Label(content, 
                text="⚠ WARNING: OBS may have recording issues!\n\n"
                     "Please check your OBS Studio to ensure:\n"
                     "• Recording is still active\n"
                     "• Correct scene/display is selected\n"
                     "• Audio levels are normal\n"
                     "• Storage space is sufficient",
                bg='#1e1e1e', fg='#e1e1e1', 
                font=('Segoe UI', 10),
                justify='left').pack(padx=15, pady=15, anchor='w')
    
    def start_move(self, event):
        self.x = event.x
        self.y = event.y
    
    def on_move(self, event):
        x = self.root.winfo_x() + event.x - self.x
        y = self.root.winfo_y() + event.y - self.y
        self.root.geometry(f"+{x}+{y}")
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    if os.name == 'nt':
        try:
            import ctypes
            ctypes.windll.user32.ShowWindow(ctypes.windll.kernel32.GetConsoleWindow(), 0)
        except:
            pass
    
    app = OBSWarningDialog()
    app.run()