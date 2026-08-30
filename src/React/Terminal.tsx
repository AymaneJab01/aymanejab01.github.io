import React, { useEffect, useRef, useState } from "react";

type TerminalLine = {
  type: "command" | "output" | "success" | "error" | "info";
  content: string;
};

type Project = {
  id: number;
  key: string;
  name: string;
  category: string;
  tags: string[];
  description: string;
  href: string;
  // If the project lives on the same page (like the terminal itself),
  // set anchorId so we scroll instead of doing a full navigation.
  anchorId?: string;
};

const projects: Project[] = [
  {
    id: 1,
    key: "terminal",
    name: "Developer Terminal",
    category: "Interactive",
    tags: ["Astro", "TypeScript", "Interactive UI"],
    description:
      "An interactive terminal built directly into the portfolio for exploring work, skills and info.",
    href: "/#terminal",
    anchorId: "terminal",
  },
  {
    id: 2,
    key: "movie-ranking",
    name: "Movie Ranking",
    category: "Web App",
    tags: ["Astro", "UI", "Movies"],
    description:
      "A movie ranking interface where films can be explored through covers, ratings and reviews.",
    href: "/projects/movie-ranking",
  },
  {
    id: 3,
    key: "weather",
    name: "Weather Dashboard",
    category: "Live Data",
    tags: ["Astro", "API", "Live Weather"],
    description:
      "A dynamic weather dashboard showing live conditions for Alcoi and Valencia.",
    href: "/projects/weather",
  },
  {
    id: 4,
    key: "visualizer",
    name: "Algorithm Visualizer",
    category: "CS Fundamentals",
    tags: ["Astro", "TypeScript", "Data Structures & Algorithms"],
    description:
      "Watch sorting algorithms, hash table chaining and pathfinding (Dijkstra, A*) run step by step.",
    href: "/projects/visualizer",
  },
  {
    id: 5,
    key: "network",
    name: "Network Protocol Simulator",
    category: "Networking",
    tags: ["Astro", "TypeScript", "TCP/UDP"],
    description:
      "Simulates the TCP three-way handshake, packet loss/retransmission, and byte-stream framing.",
    href: "/projects/network",
  },
  {
    id: 6,
    key: "cpu",
    name: "CPU Simulator",
    category: "Computer Architecture",
    tags: ["Astro", "TypeScript", "Assembly"],
    description:
      "A tiny 8-register CPU stepping through fetch, decode and execute one instruction at a time.",
    href: "/projects/Cpu",
  },
  {
    id: 7,
    key: "expense-splitter",
    name: "Expense Splitter",
    category: "Flutter App",
    tags: ["Flutter", "Dart", "Mobile"],
    description:
      "A Flutter app for splitting group expenses and minimizing the transfers needed to settle up.",
    href: "/projects/expense-splitter/",
  },
];

const initialLines: TerminalLine[] = [
  {
    type: "info",
    content: "Welcome to Aymane's interactive terminal.",
  },
  {
    type: "output",
    content: 'Type "help" to see available commands.',
  },
];

const commands = [
  "help",
  "whoami",
  "about",
  "skills",
  "projects",
  "open",
  "visualizer",
  "weather",
  "movie-ranking",
  "network",
  "cpu",
  "expense-splitter",
  "notes",
  "education",
  "contact",
  "github",
  "linkedin",
  "status",
  "clear",
];

type WeatherLocation = {
  city: string;
  latitude: number;
  longitude: number;
};

// Matches the locations tracked on the Weather Dashboard project itself.
const WEATHER_LOCATIONS: WeatherLocation[] = [
  { city: "Alcoi", latitude: 38.6983, longitude: -0.4743 },
  { city: "Valencia", latitude: 39.4699, longitude: -0.3763 },
  { city: "Torrevieja", latitude: 37.9787, longitude: -0.6822 },
];

function getWeatherDescription(code: number): string {
  switch (code) {
    case 0:
      return "Clear sky";
    case 1:
      return "Mainly clear";
    case 2:
      return "Partly cloudy";
    case 3:
      return "Overcast";
    case 45:
    case 48:
      return "Fog";
    case 51:
    case 53:
    case 55:
      return "Drizzle";
    case 56:
    case 57:
      return "Freezing drizzle";
    case 61:
    case 63:
    case 65:
      return "Rain";
    case 66:
    case 67:
      return "Freezing rain";
    case 71:
    case 73:
    case 75:
    case 77:
      return "Snow";
    case 80:
    case 81:
    case 82:
      return "Rain showers";
    case 85:
    case 86:
      return "Snow showers";
    case 95:
    case 96:
    case 99:
      return "Thunderstorm";
    default:
      return "Unknown conditions";
  }
}

async function fetchLocationSummary(
  location: WeatherLocation
): Promise<{ city: string; temperature: number; description: string }> {
  const params = new URLSearchParams({
    latitude: String(location.latitude),
    longitude: String(location.longitude),
    current: "temperature_2m,weather_code",
    timezone: "auto",
  });

  const response = await fetch(
    `https://api.open-meteo.com/v1/forecast?${params.toString()}`
  );

  if (!response.ok) {
    throw new Error(`Weather request failed for ${location.city}`);
  }

  const data = (await response.json()) as {
    current: { temperature_2m: number; weather_code: number };
  };

  return {
    city: location.city,
    temperature: Math.round(data.current.temperature_2m),
    description: getWeatherDescription(data.current.weather_code),
  };
}

type RankedMovie = {
  title: string;
  rating: number;
};

// Mirrors the movie-ranking project's data (title + rating only).
const RANKED_MOVIES: RankedMovie[] = [
  { title: "Interstellar", rating: 10 },
  { title: "Ford v Ferrari", rating: 10 },
  { title: "Your Name", rating: 10 },
  { title: "Kimetsu no Yaiba: Infinity Castle", rating: 9.5 },
  { title: "Avengers: Infinity War", rating: 9 },
  { title: "Midsommar", rating: 8.5 },
  { title: "The Boy and the Heron", rating: 8 },
  { title: "Disclosure Day", rating: 7 },
  { title: "The Social Network", rating: 4.5 },
  { title: "2012", rating: 2 },
];

function findProject(query: string): Project | undefined {
  const normalized = query.trim().toLowerCase();

  if (!normalized) return undefined;

  const asNumber = Number(normalized);

  if (Number.isInteger(asNumber)) {
    return projects.find((project) => project.id === asNumber);
  }

  return projects.find(
    (project) =>
      project.key === normalized ||
      project.key.includes(normalized) ||
      project.name.toLowerCase().includes(normalized)
  );
}

export default function Terminal() {
  const [input, setInput] = useState("");
  const [lines, setLines] = useState<TerminalLine[]>(initialLines);
  const [history, setHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);

  const inputRef = useRef<HTMLInputElement>(null);
  const terminalBodyRef = useRef<HTMLDivElement>(null);

  const addLines = (newLines: TerminalLine[]) => {
    setLines((previous) => [...previous, ...newLines]);
  };

  const goToProject = (project: Project) => {
    addLines([
      {
        type: "success",
        content: `Opening ${project.name}...`,
      },
    ]);

    setTimeout(() => {
      if (project.anchorId) {
        const target = document.getElementById(project.anchorId);

        if (target) {
          target.scrollIntoView({ behavior: "smooth" });
          return;
        }
      }

      window.location.href = project.href;
    }, 250);
  };

  const showWeatherSummary = async (project?: Project) => {
    addLines([
      {
        type: "output",
        content: "Fetching live conditions for Alcoi, Valencia & Torrevieja...",
      },
    ]);

    try {
      const summaries = await Promise.all(
        WEATHER_LOCATIONS.map(fetchLocationSummary)
      );

      addLines(
        summaries.map((summary) => ({
          type: "success" as const,
          content: `  ${summary.city}: ${summary.temperature}°C, ${summary.description}`,
        }))
      );
    } catch {
      addLines([
        {
          type: "error",
          content: "Live weather is unavailable right now.",
        },
      ]);
    }

    if (project) {
      goToProject(project);
    }
  };

  const showTopMovies = (project?: Project) => {
    const top = [...RANKED_MOVIES]
      .sort((a, b) => b.rating - a.rating)
      .slice(0, 5);

    addLines([
      { type: "output", content: "Top-rated movies:" },
      ...top.map((movie) => ({
        type: "success" as const,
        content: `  ${movie.rating.toFixed(1).replace(/\.0$/, "")}/10  ${movie.title}`,
      })),
    ]);

    if (project) {
      goToProject(project);
    }
  };

  const listProjects = () => {
    addLines([
      {
        type: "output",
        content: "Projects:",
      },
      ...projects.map((project) => ({
        type: "output" as const,
        content: `  ${project.id}. ${project.name}  [${project.key}]`,
      })),
      {
        type: "info",
        content: 'Type "open <number|name>" to jump to one, e.g. "open 4" or "open visualizer".',
      },
    ]);
  };

  const executeCommand = (rawCommand: string) => {
    const command = rawCommand.trim();
    const lower = command.toLowerCase();
    const [head, ...rest] = lower.split(/\s+/);
    const argument = rest.join(" ");

    if (!command) {
      addLines([
        {
          type: "command",
          content: "",
        },
      ]);
      return;
    }

    addLines([
      {
        type: "command",
        content: command,
      },
    ]);

    switch (head) {
      case "help":
        addLines([
          { type: "output", content: "Available commands:" },
          { type: "output", content: "  about              → Learn more about me" },
          { type: "output", content: "  whoami             → Display developer information" },
          { type: "output", content: "  skills             → View technologies and skills" },
          { type: "output", content: "  projects           → List all projects" },
          { type: "output", content: "  open <n|name>      → Jump to a project by number or name" },
          { type: "output", content: "  visualizer         → Open the Algorithm Visualizer" },
          { type: "output", content: "  weather            → Show live conditions for 3 cities, then open the dashboard" },
          { type: "output", content: "  movie-ranking      → Show my top-rated movies, then open the list" },
          { type: "output", content: "  network            → Open the Network Protocol Simulator" },
          { type: "output", content: "  cpu                → Show the CPU's specs, then open the simulator" },
          { type: "output", content: "  expense-splitter   → Open the Expense Splitter app" },
          { type: "output", content: "  notes              → Open my study notes" },
          { type: "output", content: "  education          → View my computer science background" },
          { type: "output", content: "  contact            → Get in touch" },
          { type: "output", content: "  github             → Open GitHub" },
          { type: "output", content: "  linkedin           → Open LinkedIn" },
          { type: "output", content: "  status             → Check current availability" },
          { type: "output", content: "  clear              → Clear the terminal" },
        ]);
        break;

      case "whoami":
        addLines([
          {
            type: "success",
            content: "Aymane Jabrane",
          },
          {
            type: "output",
            content: "Software Developer · Computer Science",
          },
        ]);
        break;

      case "about":
        addLines([
          {
            type: "output",
            content:
              "Building a computer science journey through code, systems and creative ideas.",
          },
          {
            type: "output",
            content:
              "Interested in software development, systems, programming and technology.",
          },
        ]);
        break;

      case "skills":
        addLines([
          {
            type: "output",
            content: "Technologies & areas:",
          },
          {
            type: "success",
            content:
              "Java · JavaScript · TypeScript · Flutter · Astro · React",
          },
          {
            type: "success",
            content:
              "Git · GitHub · Linux · Data Structures · Algorithms · Systems",
          },
        ]);
        break;

      case "projects":
        listProjects();

        setTimeout(() => {
          document
            .getElementById("projects")
            ?.scrollIntoView({ behavior: "smooth" });
        }, 150);
        break;

      case "open": {
        const project = findProject(argument);

        if (!project) {
          addLines([
            {
              type: "error",
              content: argument
                ? `No project matching "${argument}".`
                : "Usage: open <number|name>",
            },
            {
              type: "info",
              content: 'Type "projects" to see the full list.',
            },
          ]);
          break;
        }

        if (project.key === "movie-ranking") {
          showTopMovies(project);
          break;
        }

        if (project.key === "weather") {
          void showWeatherSummary(project);
          break;
        }

        if (project.key === "visualizer") {
          addLines([
            { type: "output", content: "Algorithm Visualizer — three interactive references:" },
            { type: "success", content: "  sorting     → Bubble, Selection, Insertion, Merge, Quick Sort" },
            { type: "success", content: "  hash table  → 8 buckets, separate chaining, live load factor" },
            { type: "success", content: "  pathfinding → BFS, Dijkstra, A* on a drawable grid" },
          ]);
          goToProject(project);
          break;
        }

        if (project.key === "cpu") {
          addLines([
            { type: "output", content: "CPU Simulator — a tiny 8-register machine:" },
            { type: "success", content: "  8 general-purpose registers (R0–R7)" },
            { type: "success", content: "  32 addressable memory cells" },
            { type: "success", content: "  9 instructions: MOV, ADD, SUB, LOAD, STORE, CMP, JMP, JZ, HALT" },
            { type: "success", content: "  Fetch → Decode → Execute, one instruction at a time" },
          ]);
          goToProject(project);
          break;
        }

        goToProject(project);
        break;
      }

      case "visualizer": {
        const project = findProject("visualizer");

        addLines([
          { type: "output", content: "Algorithm Visualizer — three interactive references:" },
          { type: "success", content: "  sorting     → Bubble, Selection, Insertion, Merge, Quick Sort" },
          { type: "success", content: "  hash table  → 8 buckets, separate chaining, live load factor" },
          { type: "success", content: "  pathfinding → BFS, Dijkstra, A* on a drawable grid" },
          { type: "info", content: "Supports EN / FR / ES." },
        ]);

        if (project) {
          goToProject(project);
        }

        break;
      }

      case "weather": {
        const project = findProject("weather");
        void showWeatherSummary(project);
        break;
      }

      case "movie-ranking": {
        const project = findProject("movie-ranking");
        showTopMovies(project);
        break;
      }

      case "cpu": {
        const project = findProject("cpu");

        addLines([
          { type: "output", content: "CPU Simulator — a tiny 8-register machine:" },
          { type: "success", content: "  8 general-purpose registers (R0–R7)" },
          { type: "success", content: "  32 addressable memory cells" },
          { type: "success", content: "  9 instructions: MOV, ADD, SUB, LOAD, STORE, CMP, JMP, JZ, HALT" },
          { type: "success", content: "  Fetch → Decode → Execute, one instruction at a time" },
        ]);

        if (project) {
          goToProject(project);
        }

        break;
      }

      case "network":
      case "expense-splitter": {
        const project = findProject(head);

        if (project) {
          goToProject(project);
        }

        break;
      }

      case "notes":
        addLines([
          {
            type: "output",
            content: "Opening study notes...",
          },
        ]);

        setTimeout(() => {
          document
            .getElementById("notes")
            ?.scrollIntoView({ behavior: "smooth" });
        }, 150);
        break;

      case "education":
        addLines([
          {
            type: "output",
            content: "Computer Science",
          },
          {
            type: "output",
            content: "Software · Systems · Algorithms · Programming",
          },
        ]);
        break;

      case "contact":
        addLines([
          {
            type: "output",
            content: "Opening contact section...",
          },
        ]);

        setTimeout(() => {
          document
            .getElementById("contact")
            ?.scrollIntoView({ behavior: "smooth" });
        }, 150);
        break;

      case "github":
        addLines([
          {
            type: "success",
            content: "Opening GitHub...",
          },
        ]);

        setTimeout(() => {
          window.open(
            "https://github.com/AymaneJab01",
            "_blank",
            "noopener,noreferrer"
          );
        }, 250);
        break;

      case "linkedin":
        addLines([
          {
            type: "success",
            content: "Opening LinkedIn...",
          },
        ]);

        setTimeout(() => {
          window.open(
            "https://www.linkedin.com/in/aymane-jabrane-73025726a/",
            "_blank",
            "noopener,noreferrer"
          );
        }, 250);
        break;

      case "status":
        addLines([
          {
            type: "success",
            content: "● ONLINE",
          },
          {
            type: "output",
            content: "Open to opportunities",
          },
        ]);
        break;

      case "clear":
        setLines([]);
        break;

      default:
        addLines([
          {
            type: "error",
            content: `command not found: ${command}`,
          },
          {
            type: "info",
            content: 'Type "help" for available commands.',
          },
        ]);
        break;
    }
  };

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();

    const command = input.trim();

    if (command) {
      setHistory((previous) => [...previous, command]);
    }

    setHistoryIndex(-1);
    executeCommand(command);
    setInput("");
  };

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "ArrowUp") {
      event.preventDefault();

      if (history.length === 0) return;

      const nextIndex =
        historyIndex === -1
          ? history.length - 1
          : Math.max(0, historyIndex - 1);

      setHistoryIndex(nextIndex);
      setInput(history[nextIndex]);
    }

    if (event.key === "ArrowDown") {
      event.preventDefault();

      if (history.length === 0) return;

      if (historyIndex === -1) return;

      const nextIndex = historyIndex + 1;

      if (nextIndex >= history.length) {
        setHistoryIndex(-1);
        setInput("");
      } else {
        setHistoryIndex(nextIndex);
        setInput(history[nextIndex]);
      }
    }

    if (event.key === "Tab") {
      event.preventDefault();

      const matchingCommand = commands.find((command) =>
        command.startsWith(input.toLowerCase())
      );

      if (matchingCommand) {
        setInput(matchingCommand);
      }
    }
  };

  useEffect(() => {
    terminalBodyRef.current?.scrollTo({
      top: terminalBodyRef.current.scrollHeight,
      behavior: "smooth",
    });
  }, [lines]);

  useEffect(() => {
    const focusInput = () => {
      inputRef.current?.focus();
    };

    focusInput();

    const terminal = terminalBodyRef.current;

    terminal?.addEventListener("click", focusInput);

    return () => {
      terminal?.removeEventListener("click", focusInput);
    };
  }, []);

  return (
    <div
      className="terminal-window"
      onClick={() => inputRef.current?.focus()}
    >
      {/* Terminal header */}
      <div className="terminal-header">
        <div className="terminal-controls">
          <span className="terminal-dot terminal-dot-red" />
          <span className="terminal-dot terminal-dot-yellow" />
          <span className="terminal-dot terminal-dot-green" />
        </div>

        <div className="terminal-title">
          <span>aymane@portfolio</span>
          <span className="terminal-separator">—</span>
          <span>zsh</span>
        </div>

        <div className="terminal-header-space" />
      </div>

      {/* Terminal body */}
      <div
        ref={terminalBodyRef}
        className="terminal-body"
        role="log"
        aria-live="polite"
      >
        <div className="terminal-system-line">
          <span className="terminal-green">●</span>
          <span> Aymane's Portfolio Terminal</span>
        </div>

        <div className="terminal-system-line terminal-muted">
          Secure client-side environment · v1.0.0
        </div>

        <div className="terminal-divider" />

        {lines.map((line, index) => (
          <div
            key={`${index}-${line.content}`}
            className={`terminal-line terminal-line-${line.type}`}
          >
            {line.type === "command" ? (
              <div className="terminal-command">
                <span className="terminal-prompt">
                  aymane@portfolio
                </span>
                <span className="terminal-path">~</span>
                <span className="terminal-symbol">%</span>
                <span className="terminal-command-text">
                  {line.content}
                </span>
              </div>
            ) : (
              <div className="terminal-output">{line.content}</div>
            )}
          </div>
        ))}

        {/* Current prompt */}
        <form
          className="terminal-command terminal-active-command"
          onSubmit={handleSubmit}
        >
          <span className="terminal-prompt">
            aymane@portfolio
          </span>

          <span className="terminal-path">~</span>

          <span className="terminal-symbol">%</span>

          <input
            ref={inputRef}
            value={input}
            onChange={(event) => setInput(event.target.value)}
            onKeyDown={handleKeyDown}
            className="terminal-input"
            autoComplete="off"
            autoCapitalize="off"
            spellCheck={false}
            aria-label="Terminal command input"
          />

          <span className="terminal-cursor" />
        </form>
      </div>

      {/* Terminal footer */}
      <div className="terminal-footer">
        <span>
          <span className="terminal-green">●</span> connected
        </span>

        <span>
          ↑ ↓ history&nbsp;&nbsp;·&nbsp;&nbsp;TAB autocomplete&nbsp;&nbsp;·&nbsp;&nbsp;ENTER run
        </span>
      </div>
    </div>
  );
}