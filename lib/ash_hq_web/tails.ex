defmodule AshHqWeb.Tails do
  @themes [
    dark: [
      bg: [
        primary: "bg-primary-dark-400"
      ],
      border: [
        primary: "border-xl"
      ]
    ],
    default: [
      bg: [
        base: [
          content: ""
        ],
        neutral: "",
        neutral: [
          focus: ""
        ],
        primary: "bg-primary-light-400",
        primary: [
          focus: ""
        ],
        secondary: "",
        secondary: [
          focus: ""
        ],
        accent: "",
        accent: [
          focus: ""
        ],
        info: "",
        info: [
          focus: ""
        ],
        success: "",
        success: [
          focus: ""
        ],
        warning: "",
        warning: [
          focus: ""
        ],
        error: "",
        error: [
          focus: ""
        ],
        glass: "",
        glass: [
          focus: ""
        ]
      ],
      text: [
        primary: "",
        primary: [
          content: ""
        ],
        neutral: "",
        neutral: [
          content: ""
        ],
        secondary: "",
        secondary: [
          content: ""
        ],
        accent: "",
        accent: [
          content: ""
        ],
        info: "",
        info: [
          content: ""
        ],
        success: "",
        success: [
          content: ""
        ],
        warning: "",
        warning: [
          content: ""
        ],
        error: "",
        error: [
          content: ""
        ],
        glass: "",
        glass: [
          content: ""
        ]
      ],
      border: [
        primary: "border-xl",
        primary: [
          focus: ""
        ],
        secondary: "",
        secondary: [
          focus: ""
        ],
        neutral: "",
        neutral: [
          focus: ""
        ],
        accent: "",
        accent: [
          focus: ""
        ],
        info: "",
        info: [
          focus: ""
        ],
        success: "",
        success: [
          focus: ""
        ],
        warning: "",
        warning: [
          focus: ""
        ],
        error: "",
        error: [
          focus: ""
        ],
        glass: "",
        glass: [
          focus: ""
        ]
      ],
      button: [
        border: "border",
        rounded: [
          tr: "rounded-tr-lg",
          br: "rounded-br-lg",
          tl: "rounded-tl-lg",
          bl: "rounded-bl-lg"
        ],
        text: [
          case: "uppercase"
        ],
        focus: [
          scale: "scale-[0.95]",
          visible: [
            outline: "outline-[2px_solid] outline-black",
            primary: [
              outline: "outline-[2px_solid] outline-black"
            ]
          ]
        ]
      ]
    ]
  ]

  use Tails, themes: @themes, otp_app: :ash_hq
end
