# Ash Framework Interactive Animation Plan

## Overview
Create an interactive, Tailwind-inspired animation for the Ash Framework home page that demonstrates how Resources evolve as extensions are added. The animation will show code being typed on the left with visual representations appearing on the right to illustrate the growing capabilities.

**Placement**: The animation will be positioned immediately after the "Get Started" button in the hero section, with the book and newsletter content moved below it.

**Behavior**: The animation will start automatically when scrolled into view and loop continuously.

## Goals
- Visually demonstrate Ash's "Model your domain, derive the rest" philosophy
- Show the progressive enhancement of Resources through extensions
- Create an engaging, educational experience for visitors
- Match the existing Ash brand aesthetic (dark theme with orange/red accents)

## Animation Sequence

### Stage 1: Pure Behavior (Actions)
**Left Panel**: Show typing of basic action definition
```elixir
defmodule MyBlog.Post do
  use Ash.Resource
  
  actions do
    action :analyze_text, :map do
      argument :text, :string, allow_nil?: false
      
      run fn input, _ ->
        words = String.split(input.arguments.text)
        {:ok, %{
          word_count: length(words),
          reading_time: div(length(words), 200) + 1
        }}
      end
    end
  end
end
```

**Right Panel**: Display a function interface visualization
- Show function signature: `analyze_text(text: String) -> Map`
- Animated arrow showing input/output flow
- Visual representation of the analysis result

### Stage 2: Add Persistence (AshPostgres)
**Left Panel**: Add data layer and attributes
```elixir
use Ash.Resource,
  data_layer: AshPostgres.DataLayer

postgres do
  table "posts"
  repo MyBlog.Repo
end

attributes do
  uuid_primary_key :id
  attribute :title, :string, allow_nil?: false
  attribute :content, :string
  attribute :status, :atom, 
    constraints: [one_of: [:draft, :published]], 
    default: :draft
    
  create_timestamp :created_at
  update_timestamp :updated_at
end

actions do
  defaults [:read, :destroy, 
    create: [:title, :content], 
    update: [:title, :content, :status]]
    
  # analyze_text action remains...
end
```

**Right Panel**: 
- Previous function interface remains
- Add PostgreSQL table visualization below
- Show table schema with columns
- Animate data flowing into the table

### Stage 3: Add GraphQL API
**Left Panel**: Add GraphQL extension
```elixir
use Ash.Resource,
  # ...
  extensions: [AshGraphql.Resource]
  
graphql do
  type :post
end
```

**Right Panel**:
- Previous elements remain
- Add GraphQL query panel
- Show auto-generated queries/mutations
- Animate GraphQL request/response

### Stage 4: Add Encryption (AshCloak)
**Left Panel**: Add Cloak extension
```elixir
extensions: [AshGraphql.Resource, AshCloak.Resource]

cloak do
  vault MyBlog.Vault
  attributes [:content]
end
```

**Right Panel**:
- Update PostgreSQL visualization to show encrypted field
- Add lock icon on content field
- Show encryption/decryption flow animation

### Stage 5: Add State Machine
**Left Panel**: Add state machine
```elixir
extensions: [AshGraphql.Resource, AshCloak.Resource, AshStateMachine]

state_machine do
  initial_states [:draft]
  transitions do
    transition :publish, from: :draft, to: :published
  end
end
```

**Right Panel**:
- Add state diagram visualization
- Show states and transitions
- Animate state changes
- Update GraphQL panel to show new mutations

## Technical Implementation

### Structure
```
├── app.js (main animation logic)
├── components/
│   ├── CodeEditor.js (left panel with typing effect)
│   ├── VisualizationPanel.js (right panel container)
│   ├── FunctionInterface.js (Stage 1)
│   ├── PostgresTable.js (Stage 2)
│   ├── GraphQLPanel.js (Stage 3)
│   ├── EncryptionFlow.js (Stage 4)
│   └── StateMachine.js (Stage 5)
└── styles/
    └── animation.css (custom animations)
```

### Key Features
1. **Typing Animation**: Realistic typing effect with cursor
2. **Progressive Enhancement**: Each stage builds on the previous
3. **Smooth Transitions**: Elements fade in/slide as code is typed
4. **Interactive Controls**: Play/pause, skip to stages, speed control
5. **Responsive Design**: Works on mobile and desktop
6. **Performance**: Use CSS transforms and will-change for smooth 60fps

### Animation Timeline
- Total duration: ~45 seconds per loop
- Stage transitions: 2s each
- Typing speed: 30-60ms per character
- Pause between stages: 2s
- Pause before loop restart: 3s
- Auto-start: When element is 50% visible in viewport

### Visual Design
- **Colors**: Match Ash brand (primary-dark-500, primary-light-500)
- **Typography**: Monospace for code, system font for UI
- **Effects**: Subtle glow matching existing shadows (e.g., shadow-[0_0_20px_#FF5757])
- **Layout**: Split view with code editor (45%) and visualizations (55%)
- **Style**: Relatively plain/minimalist matching the theme's aesthetic
- **Container**: Use similar styling to the installer section (backdrop-blur-lg bg-slate-950/50 rounded-2xl border border-primary-light-500/30)

## Implementation Steps

### Phase 1: Core Infrastructure & Layout
1. Reorganize home.html.heex:
   - Move book and newsletter sections below animation
   - Add animation container after "Get Started" button
2. Create base animation controller in app.js
3. Implement typing effect engine with Intersection Observer
4. Build stage management system with looping

### HTML Structure
```html
<!-- After Get Started button -->
<div id="ash-animation" class="mt-16 mb-16">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="backdrop-blur-lg bg-slate-950/50 rounded-2xl border border-primary-light-500/30 p-8">
      <h2 class="text-2xl font-bold text-center mb-8 text-primary-light-200">
        See Ash in Action
      </h2>
      <div class="grid lg:grid-cols-2 gap-8">
        <!-- Code Editor -->
        <div class="relative">
          <div class="bg-slate-900 rounded-lg p-4 font-mono text-sm overflow-x-auto">
            <pre id="code-display"><code></code></pre>
            <span class="typing-cursor"></span>
          </div>
        </div>
        <!-- Visualization Panel -->
        <div id="visualization-panel" class="relative">
          <!-- Dynamic content -->
        </div>
      </div>
      <!-- Progress indicator -->
      <div class="mt-6 flex justify-center gap-2">
        <div class="stage-dot" data-stage="1"></div>
        <div class="stage-dot" data-stage="2"></div>
        <div class="stage-dot" data-stage="3"></div>
        <div class="stage-dot" data-stage="4"></div>
        <div class="stage-dot" data-stage="5"></div>
      </div>
    </div>
  </div>
</div>
```

### Phase 2: Visual Components
1. Create code editor component with syntax highlighting
2. Build individual visualization components
3. Implement transitions between stages
4. Add progress indicator

### Phase 3: Polish & Optimization
1. Add interactive controls
2. Optimize performance
3. Add accessibility features
4. Test across devices

## Considerations
- **Performance**: Use requestAnimationFrame for smooth animations
- **Accessibility**: Provide pause controls and reduced motion support
- **Fallback**: Static image for users with JavaScript disabled
- **Mobile**: Stack panels vertically on small screens using lg:grid-cols-2
- **Scroll Performance**: Use Intersection Observer to only animate when visible
- **Memory**: Clean up animations when out of view to prevent memory leaks

## Dependencies
- No external animation libraries (pure CSS/JS)
- Use existing Tailwind classes where possible
- Leverage Phoenix LiveView hooks if needed

## Success Metrics
- Smooth 60fps animation performance
- Clear visual representation of Ash concepts
- Engaging user experience that encourages exploration
- Improved understanding of Ash's capabilities