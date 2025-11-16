/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Custom color palette matching the modernized UI
        primary: {
          bg: '#1E1E2E',
          surface: '#242438',
          elevated: '#2D2D44',
          secondary: '#2A2A3E',
          tertiary: '#363650',
        },
        accent: {
          primary: '#7AA2F7',
          secondary: '#BB9AF7',
          success: '#9ECE6A',
          warning: '#E0AF68',
          error: '#F7768E',
        },
        text: {
          primary: '#C0CAF5',
          secondary: '#9AA5CE',
          tertiary: '#565F89',
        },
        ui: {
          border: '#414868',
          highlight: '#33467C',
        }
      },
      fontFamily: {
        sans: ['Segoe UI', 'system-ui', 'sans-serif'],
        mono: ['Consolas', 'Monaco', 'monospace'],
        display: ['Segoe UI Semibold', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        '4xl': '2rem',
      },
      spacing: {
        '18': '4.5rem',
      },
      backdropBlur: {
        xs: '2px',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'scale-in': 'scaleIn 0.2s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        scaleIn: {
          '0%': { transform: 'scale(0.95)', opacity: '0' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}
