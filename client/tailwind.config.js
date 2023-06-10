/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.js", "./public/index.html"],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['"Poppins"'],
        'jost': ['"Jost"'],
        'poppins': ['"Poppins"'],
        'mono': ['"Source Code Pro"'],
      },
      colors: {
        'tblue': '#050824',
        'tpurple': '#A882DD',
        'tpink': '#e67ac5',
        'tteal': '#4fc9af',
        'torange': '#F87060',
        'tyellow': '#d1a919',
        'tgray': '#4b4952',
        'tgreen': '#3c826d'
      },
      animation: {
        'spin': 'spin 4s infinite',
        'wiggle': 'wiggle 0.25s infinite',
        'pop': 'pop 0.25s linear',
        'click': 'click 0.05s linear'
      },
      keyframes: {
        'spin': {
          '0%': { transform: 'rotate(0deg)' },
          '25%': { transform: 'rotate(180deg)' },
          '50%': { transform: 'rotate(180deg)' },
          '75%': { transform: 'rotate(360deg)' }
        },
        'wiggle': {
          '0%': { transform: 'rotate(1.5deg)', animationTimingFunction: 'ease-in' },
          '50%': { transform: 'rotate(-3deg)', animationTimingFunction: 'ease-out' },
        },
        'pop': {
          '50%': {transform: 'scale(1.2)'}
        },
        'click': {
          '50%': { transform: 'scale(2)' }
        }
      }
    }
  },
  plugins: [],
}
