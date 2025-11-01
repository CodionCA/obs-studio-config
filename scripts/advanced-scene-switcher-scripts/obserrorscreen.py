import tkinter as tk
import threading
import time
import os

class RoundedButton(tk.Canvas):
    def __init__(self, parent, text, command, bg_color, fg_color='white', width=140, height=35):
        super().__init__(parent, width=width, height=height, highlightthickness=0, 
                        bg=parent['bg'])
        
        self.bg_color = bg_color
        self.hover_color = self.darken_color(bg_color)
        self.command = command
        self.text = text
        self.fg_color = fg_color
        
        self.draw_button()
        
        self.bind("<Button-1>", lambda e: self.command())
        self.bind("<Enter>", self.on_enter)
        self.bind("<Leave>", self.on_leave)
    
    def darken_color(self, color):
        color = color.lstrip('#')
        rgb = tuple(int(color[i:i+2], 16) for i in (0, 2, 4))
        darkened = tuple(max(0, c - 30) for c in rgb)
        return f"#{darkened[0]:02x}{darkened[1]:02x}{darkened[2]:02x}"
    
    def draw_button(self, is_hover=False):
        self.delete("all")
        color = self.hover_color if is_hover else self.bg_color
        
        x1, y1, x2, y2 = 2, 2, self.winfo_reqwidth()-2, self.winfo_reqheight()-2
        radius = 8
        
        self.create_arc(x1, y1, x1+radius*2, y1+radius*2, start=90, extent=90, 
                       fill=color, outline=color)
        self.create_arc(x2-radius*2, y1, x2, y1+radius*2, start=0, extent=90, 
                       fill=color, outline=color)
        self.create_arc(x1, y2-radius*2, x1+radius*2, y2, start=180, extent=90, 
                       fill=color, outline=color)
        self.create_arc(x2-radius*2, y2-radius*2, x2, y2, start=270, extent=90, 
                       fill=color, outline=color)
        
        self.create_rectangle(x1+radius, y1, x2-radius, y2, fill=color, outline=color)
        self.create_rectangle(x1, y1+radius, x2, y2-radius, fill=color, outline=color)
        
        self.create_text(self.winfo_reqwidth()//2, self.winfo_reqheight()//2, 
                        text=self.text, fill=self.fg_color, 
                        font=('Segoe UI', 10, 'bold'))
    
    def on_enter(self, event):
        self.configure(cursor='hand2')
        self.draw_button(True)
    
    def on_leave(self, event):
        self.configure(cursor='')
        self.draw_button(False)

class OBSWarningDialog:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("OBS Recording Alert")
        self.root.geometry("480x320")
        self.root.resizable(True, True)
        self.root.minsize(400, 280)
        
        self.root.configure(bg='#1e1e1e')
        self.root.attributes('-alpha', 0.95)
        self.root.eval('tk::PlaceWindow . center')
        self.root.attributes('-topmost', True)
        
        self.dismissed = False
        self.is_blinking = True
        
        self.setup_ui()
        self.start_blinking_animation()
    
    def setup_ui(self):
        main_frame = tk.Frame(self.root, bg='#2d2d30', highlightbackground='#ff6b35', 
                             highlightthickness=2)
        main_frame.pack(fill='both', expand=True, padx=1, pady=1)
        
        title_frame = tk.Frame(main_frame, bg='#2d2d30', height=45)
        title_frame.pack(fill='x')
        title_frame.pack_propagate(False)
        
        title_container = tk.Frame(title_frame, bg='#2d2d30')
        title_container.pack(side='left', expand=True, fill='both', padx=10)
        
        title_content = tk.Frame(title_container, bg='#2d2d30')
        title_content.pack(expand=True)
        
        warning_label = tk.Label(title_content, text="⚠", 
                                bg='#2d2d30', fg='#ff6b35', 
                                font=('Segoe UI', 16))
        warning_label.pack(side='left', padx=(0, 8))
        
        title_label = tk.Label(title_content, text="OBS Recording Issue Detected", 
                              bg='#2d2d30', fg='#ffffff', 
                              font=('Segoe UI', 13, 'bold'))
        title_label.pack(side='left')
        
        close_btn_frame = tk.Frame(title_frame, bg='#2d2d30')
        close_btn_frame.pack(side='right', padx=10)
        
        self.close_btn = RoundedButton(close_btn_frame, "✕", 
                                      self.dismiss_dialog, '#d13438', 
                                      width=30, height=30)
        self.close_btn.pack(pady=7)
        
        title_container.bind('<Button-1>', self.start_move)
        title_container.bind('<B1-Motion>', self.on_move)
        title_content.bind('<Button-1>', self.start_move)
        title_content.bind('<B1-Motion>', self.on_move)
        title_label.bind('<Button-1>', self.start_move)
        title_label.bind('<B1-Motion>', self.on_move)
        warning_label.bind('<Button-1>', self.start_move)
        warning_label.bind('<B1-Motion>', self.on_move)
        
        content_frame = tk.Frame(main_frame, bg='#1e1e1e')
        content_frame.pack(fill='both', expand=True, padx=25, pady=20)
        
        self.message_label = tk.Label(content_frame, 
                                     text="⚠ WARNING: OBS may have recording issues!\n\n"
                                          "Please check your OBS Studio to ensure:\n"
                                          "• Recording is still active\n"
                                          "• Correct scene/display is selected\n"
                                          "• Audio levels are normal\n"
                                          "• Storage space is sufficient\n",
                                     bg='#1e1e1e', fg='#e1e1e1', 
                                     font=('Segoe UI', 12),
                                     wraplength=400, justify='left')
        self.message_label.pack(pady=(0, 20))
        
        status_frame = tk.Frame(content_frame, bg='#1e1e1e')
        status_frame.pack(pady=(0, 20))
        
        status_label = tk.Label(status_frame, 
                               text="Click 'Dismiss' when you've verified OBS is working correctly",
                               bg='#1e1e1e', fg='#888888', 
                               font=('Segoe UI', 10, 'italic'))
        status_label.pack()
        
        button_container = tk.Frame(main_frame, bg='#252526')
        button_container.pack(fill='x', pady=10)
        
        btn_holder = tk.Frame(button_container, bg='#252526')
        btn_holder.pack()
        
        self.dismiss_btn = RoundedButton(btn_holder, "Dismiss", 
                                        self.dismiss_dialog, '#0078d4', 
                                        width=130, height=38)
        self.dismiss_btn.pack(side='left', padx=(0, 15))
    
    def start_blinking_animation(self):
        def blink():
            colors = ['#ff6b35', '#ff0000']
            color_index = 0
            
            while not self.dismissed and self.is_blinking:
                try:
                    for widget in self.root.winfo_children():
                        self.update_warning_colors(widget, colors[color_index])
                    color_index = (color_index + 1) % len(colors)
                    time.sleep(0.8)
                except:
                    break
        
        blink_thread = threading.Thread(target=blink, daemon=True)
        blink_thread.start()
    
    def update_warning_colors(self, widget, color):
        try:
            if isinstance(widget, tk.Label) and widget.cget('text') == '⚠':
                widget.config(fg=color)
            for child in widget.winfo_children():
                self.update_warning_colors(child, color)
        except:
            pass
    
    def start_move(self, event):
        self.x = event.x
        self.y = event.y
    
    def on_move(self, event):
        deltax = event.x - self.x
        deltay = event.y - self.y
        x = self.root.winfo_x() + deltax
        y = self.root.winfo_y() + deltay
        self.root.geometry(f"+{x}+{y}")
    
    def dismiss_dialog(self):
        self.dismissed = True
        self.is_blinking = False
        self.root.destroy()
    
    def run(self):
        try:
            self.root.mainloop()
        except KeyboardInterrupt:
            self.dismiss_dialog()

if __name__ == "__main__":
    if os.name == 'nt':
        try:
            import ctypes
            ctypes.windll.user32.ShowWindow(ctypes.windll.kernel32.GetConsoleWindow(), 0)
        except:
            pass
    
    app = OBSWarningDialog()
    app.run()