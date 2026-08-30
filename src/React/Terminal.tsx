
import React, { useEffect, useMemo, useRef, useState } from "react";

type TerminalLineType =
  | "command"
  | "output"
  | "success"
  | "error"
  | "info"
  | "muted"
  | "accent";

type TerminalLine = {
  id: number;
  type: TerminalLineType;
  content: string;
};

type Project = {
  id: string;
  number: string;
  name: string;
  description: string;
  category: string;
  technologies: string[];
  path: string;
  route: string;
};

const PROJECTS: Project[] = [
  {
    id: "terminal",
    number: "01",
    name: "Developer Terminal",
    description:
      "Interactive developer terminal integrated directly into the portfolio.",
    category: "Interactive UI",
    technologies: ["Astro", "React", "TypeScript"],
    path: "projects/01-terminal",
    route: "/#terminal",
  },
  {
    id: "movies",
    number: "02",
    name: "Movie Ranking",
    description:
      "Movie ranking interface with covers, ratings and personal reviews.",
    category: "Web App",
    technologies: ["Astro", "UI"],
    path: "projects/02-movie-ranking",
    route: "/projects/movie-ranking",
  },
  {
    id: "weather",
    number: "03",
    name: "Weather Dashboard",
    description:
      "Live weather dashboard for Alcoi and Valencia using weather data.",
    category: "Live Data",
    technologies: ["Astro", "API", "Open-Meteo"],
    path: "projects/03-weather",
    route: "/projects/weather",
  },
  {
    id: "visualizer",
    number: "04",
    name: "Algorithm Visualizer",
    description:
      "Interactive visualization of sorting, hashing and pathfinding algorithms.",
    category: "CS Fundamentals",
    technologies: ["Astro", "TypeScript", "Algorithms"],
    path: "projects/04-algorithm-visualizer",
    route: "/projects/visualizer",
  },
  {
    id: "network",
    number: "05",
    name: "Network Protocol Simulator",
    description:
      "Interactive TCP/UDP simulator covering handshakes, packet loss and framing.",
    category: "Networking",
    technologies: ["Astro", "TypeScript", "TCP/UDP"],
    path: "projects/05-network-simulator",
    route: "/projects/network",
  },
  {
    id: "cpu",
    number: "06",
    name: "CPU Simulator",
    description:
      "A tiny 8-register CPU demonstrating fetch, decode, execute, registers and memory.",
    category: "Computer Architecture",
    technologies: ["Astro", "TypeScript", "Assembly"],
    path: "projects/06-cpu-simulator",
    route: "/projects/Cpu",
  },
  {
    id: "expenses",
    number: "07",
    name: "Expense Splitter",
    description:
      "Flutter application for splitting group expenses and minimizing transfers.",
    category: "Flutter App",
    technologies: ["Flutter", "Dart", "Mobile"],
    path: "projects/07-expense-splitter",
    route: "/projects/expense-splitter/",
  },
];

const FILES: Record<string, string[]> = {
  "~": [
    "about.txt",
    "skills.txt",
    "education.txt",
    "contact.txt",
    "projects",
  ],

  "~/projects": [
    "01-terminal",
    "02-movie-ranking",
    "03-weather",
    "04-algorithm-visualizer",
    "05-network-simulator",
    "06-cpu-simulator",
    "07-expense-splitter",
  ],
};

const FILE_CONTENT: Record<string, string[]> = {
  "about.txt": [
    "Aymane Jabrane",
    "",
    "Software developer and Computer Science student.",
    "",
    "Interested in software development, systems, algorithms,",
    "computer architecture, networking and interactive experiences.",
    "",
    "This portfolio is built as a collection of projects,",
    "experiments and things I am learning along the way.",
  ],

  "skills.txt": [
    "LANGUAGES",
    "  Java",
    "  JavaScript",
    "  TypeScript",
    "  Dart",
    "",
    "FRAMEWORKS & TOOLS",
    "  Astro",
    "  React",
    "  Flutter",
    "  Git",
    "  GitHub",
    "",
    "COMPUTER SCIENCE",
    "  Data Structures",
    "  Algorithms",
    "  Operating Systems",
    "  Computer Architecture",
    "  Networking",
  "  Systems Programming",
  "  TCP / UDP",
  "  Assembly",
  "",
    "CURRENT FOCUS",
    "  Building interactive software and strengthening",
    "  systems and computer science fundamentals.",
  ],

  "education.txt": [
    "COMPUTER SCIENCE",
    "",
    "Areas of study:",
    "  • Software Engineering",
    "  • Algorithms & Data Structures",
    "  • Computer Architecture",
    "  • Operating Systems",
    "  • Computer Networks",
    "  • Programming",
  ],

  "contact.txt": [
    "CONTACT",
    "",
    "GitHub   → github.com/AymaneJab01",
    "LinkedIn → linkedin.com/in/aymane-jabrane-73025726a/",
    "",
    "Use:",
    "  github",
    "  linkedin",
  ],
};

const BASE_COMMANDS = [
  "help",
  "ls",
  "dir",
  "cd",
  "pwd",
  "cat",
  "open",
  "project",
  "projects",
  "about",
  "whoami",
  "skills",
  "stack",
  "education",
  "notes",
  "contact",
  "github",
  "linkedin",
  "status",
  "date",
  "history",
  "clear",
  "cls",
];

const PROJECT_ALIASES: Record<string, string> = {
  terminal: "terminal",
  "01": "terminal",

  movies: "movies",
  movie: "movies",
  ranking: "movies",
  "02": "movies",

  weather: "weather",
  "03": "weather",

  visualizer: "visualizer",
  algorithms: "visualizer",
  algorithm: "visualizer",
  algo: "visualizer",
  "04": "visualizer",

  network: "network",
  networking: "network",
  tcp: "network",
  udp: "network",
  "05": "network",

  cpu: "cpu",
  architecture: "cpu",
  processor: "cpu",
  "06": "cpu",

  expenses: "expenses",
  expense: "expenses",
  splitter: "expenses",
  flutter: "expenses",
  "07": "expenses",
};

let lineId = 0;

const createLine = (
  type: TerminalLineType,
  content: string
): TerminalLine => ({
  id: ++lineId,
  type,
  content,
});

const getProject = (value: string): Project | undefined => {
  const key = value.trim().toLowerCase();
  const id = PROJECT_ALIASES[key] ?? key;

  return PROJECTS.find((project) => project.id === id);
};

const getProjectFolder = (project: Project): string => {
  return project.path.split("/").pop() ?? project.id;
};

export default function Terminal() {
  const [input, setInput] = useState("");
  const [lines, setLines] = useState<TerminalLine[]>([
    createLine("info", "Welcome to Aymane's interactive terminal."),
    createLine(
      "output",
      'Type "help" to see available commands.'
    ),
  ]);

  const [history, setHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [currentPath, setCurrentPath] = useState("~");

  const inputRef = useRef<HTMLInputElement>(null);
  const terminalBodyRef = useRef<HTMLDivElement>(null);

  const allCommands = useMemo(
    () => [
      ...BASE_COMMANDS,
      ...PROJECTS.map((project) => project.id),
      ...Object.keys(PROJECT_ALIASES),
    ],
    []
  );

  const addLines = (newLines: TerminalLine[]) => {
    setLines((previous) => [...previous, ...newLines]);
  };

  const addText = (
    type: TerminalLineType,
    content: string
  ) => {
    addLines([createLine(type, content)]);
  };

  const scrollToSection = (id: string) => {
    setTimeout(() => {
      document
        .getElementById(id)
        ?.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
    }, 150);
  };

  const openProject = (project: Project) => {
    addLines([
      createLine("accent", `┌─ ${project.name}`),
      createLine("output", `│ ${project.category}`),
      createLine("output", "│"),
      createLine("output", `│ ${project.description}`),
      createLine("output", "│"),
      createLine(
        "success",
        `│ ${project.technologies.join(" · ")}`
      ),
      createLine("accent", "└────────────────────────────────────"),
      createLine(
        "success",
        `Opening ${project.route}...`
      ),
    ]);

    setTimeout(() => {
      window.location.href = project.route;
    }, 300);
  };

  const showProject = (project: Project) => {
    addLines([
      createLine("accent", `PROJECT ${project.number}`),
      createLine("success", project.name),
      createLine("output", project.description),
      createLine("muted", `Category: ${project.category}`),
      createLine(
        "muted",
        `Stack: ${project.technologies.join(" · ")}`
      ),
      createLine("muted", `Path: ${project.path}`),
      createLine(
        "info",
        `Use "open ${project.id}" to launch the project.`
      ),
    ]);
  };

  const executeCommand = (rawCommand: string) => {
    const trimmed = rawCommand.trim();

    if (!trimmed) {
      addLines([createLine("command", "")]);
      return;
    }

    const parts = trimmed.split(/\s+/);
    const command = parts[0].toLowerCase();
    const args = parts.slice(1);
    const argument = args.join(" ").trim();

    addLines([createLine("command", trimmed)]);

    switch (command) {
      case "help":
        addLines([
          createLine("accent", "AVAILABLE COMMANDS"),
          createLine("output", ""),
          createLine(
            "output",
            "  ls / dir              List files and directories"
          ),
          createLine(
            "output",
            "  cd <directory>        Change directory"
          ),
          createLine(
            "output",
            "  pwd                   Show current directory"
          ),
          createLine(
            "output",
            "  cat <file>            Read a portfolio file"
          ),
          createLine(
            "output",
            "  projects              List all projects"
          ),
          createLine(
            "output",
            "  project <name>        Inspect a project"
          ),
          createLine(
            "output",
            "  open <name>           Open a project"
          ),
          createLine("output", ""),
          createLine("output", "  about                 About me"),
          createLine("output", "  whoami                Developer identity"),
          createLine("output", "  skills / stack        Technologies"),
          createLine("output", "  education             Computer Science"),
          createLine("output", "  notes                 Study notes"),
          createLine("output", "  contact               Contact information"),
          createLine("output", ""),
          createLine("output", "  github                Open GitHub"),
          createLine("output", "  linkedin              Open LinkedIn"),
          createLine("output", "  status                Current status"),
          createLine("output", "  date                  Current date"),
          createLine("output", "  history               Command history"),
          createLine("output", "  clear / cls           Clear terminal"),
          createLine("output", ""),
          createLine(
            "muted",
            'Tip: Try "cd projects" → "ls" → "project visualizer".'
          ),
        ]);
        break;

      case "ls":
      case "dir": {
        const entries = FILES[currentPath];

        if (!entries) {
          addText(
            "error",
            `ls: cannot access '${currentPath}'`
          );
          break;
        }

        addLines([
          createLine("accent", currentPath === "~" ? "~" : currentPath),
          ...entries.map((entry) =>
            createLine(
              entry.includes(".")
                ? "output"
                : "success",
              entry.includes(".")
                ? `  ${entry}`
                : `  ${entry}/`
            )
          ),
        ]);
        break;
      }

      case "pwd":
        addText(
          "output",
          currentPath === "~"
            ? "/home/aymane"
            : `/home/aymane/${currentPath.replace("~/", "")}`
        );
        break;

      case "cd": {
        if (!argument || argument === "~") {
          setCurrentPath("~");
          addText("output", "Returned to home directory.");
          break;
        }

        if (argument === "..") {
          if (currentPath === "~/projects") {
            setCurrentPath("~");
          } else {
            setCurrentPath("~");
          }

          addText("output", "Moved to parent directory.");
          break;
        }

        const normalized = argument
          .replace(/^\/+/, "")
          .replace(/\/+$/, "")
          .toLowerCase();

        if (
          normalized === "projects" ||
          normalized === "~/projects"
        ) {
          setCurrentPath("~/projects");
          addText("output", "Changed directory to ~/projects");
          break;
        }

        const project = getProject(normalized);

        if (project && currentPath === "~/projects") {
          setCurrentPath(
            `~/projects/${getProjectFolder(project)}`
          );

          addText(
            "output",
            `Changed directory to ${getProjectFolder(project)}`
          );
          break;
        }

        addText(
          "error",
          `cd: no such directory: ${argument}`
        );
        break;
      }

      case "cat": {
        if (!argument) {
          addText("error", "cat: missing file operand");
          break;
        }

        const filename = argument.toLowerCase();

        if (filename === "projects") {
          addText(
            "error",
            "cat: projects: Is a directory"
          );
          break;
        }

        const content = FILE_CONTENT[filename];

        if (!content) {
          addText(
            "error",
            `cat: ${argument}: No such file`
          );
          break;
        }

        addLines(
          content.map((line) =>
            createLine(
              line === "" ? "output" : "output",
              line
            )
          )
        );
        break;
      }

      case "projects":
        addLines([
          createLine("accent", "PROJECT INDEX"),
          createLine("muted", ""),
          ...PROJECTS.map((project) =>
            createLine(
              "output",
              `  ${project.number}  ${project.name}`
            )
          ),
          createLine("muted", ""),
          createLine(
            "info",
            'Use "project <name>" for details.'
          ),
          createLine(
            "info",
            'Use "open <name>" to launch one.'
          ),
        ]);
        break;

      case "project": {
        if (!argument) {
          addText(
            "error",
            'Usage: project <name>'
          );
          addText(
            "info",
            "Available: terminal, movies, weather, visualizer, network, cpu, expenses"
          );
          break;
        }

        const project = getProject(argument);

        if (!project) {
          addText(
            "error",
            `project: unknown project '${argument}'`
          );
          addText(
            "info",
            'Type "projects" to see the project index.'
          );
          break;
        }

        showProject(project);
        break;
      }

      case "open": {
        if (!argument) {
          addText(
            "error",
            "Usage: open <project>"
          );
          break;
        }

        const project = getProject(argument);

        if (!project) {
          addText(
            "error",
            `open: unknown project '${argument}'`
          );
          addText(
            "info",
            "Try: visualizer, network, cpu, weather, movies, expenses"
          );
          break;
        }

        if (project.id === "terminal") {
          scrollToSection("terminal");
          addText(
            "success",
            "Terminal is already running."
          );
          break;
        }

        openProject(project);
        break;
      }

      case "about":
        addLines(
          FILE_CONTENT["about.txt"].map((line) =>
            createLine("output", line)
          )
        );
        break;

      case "whoami":
        addLines([
          createLine("success", "Aymane Jabrane"),
          createLine(
            "output",
            "Software Developer · Computer Science"
          ),
          createLine(
            "muted",
            "Systems · Algorithms · Programming · Technology"
          ),
        ]);
        break;

      case "skills":
      case "stack":
        addLines([
          createLine("accent", "TECH STACK"),
          createLine(
            "success",
            "Java · JavaScript · TypeScript · Dart"
          ),
          createLine(
            "success",
            "Astro · React · Flutter"
          ),
          createLine(
            "success",
            "Git · GitHub · Linux"
          ),
          createLine(
            "output",
            "Data Structures · Algorithms · Systems"
          ),
          createLine(
            "output",
            "Computer Architecture · Networking"
          ),
        ]);
        break;

      case "education":
        addLines(
          FILE_CONTENT["education.txt"].map((line) =>
            createLine("output", line)
          )
        );
        break;

      case "notes":
        addText("output", "Opening study notes...");

        setTimeout(() => {
          document
            .getElementById("notes")
            ?.scrollIntoView({
              behavior: "smooth",
            });
        }, 150);

        break;

      case "contact":
        addLines(
          FILE_CONTENT["contact.txt"].map((line) =>
            createLine("output", line)
          )
        );

        setTimeout(() => {
          document
            .getElementById("contact")
            ?.scrollIntoView({
              behavior: "smooth",
            });
        }, 150);

        break;

      case "github":
        addText(
          "success",
          "Opening GitHub..."
        );

        setTimeout(() => {
          window.open(
            "https://github.com/AymaneJab01",
            "_blank",
            "noopener,noreferrer"
          );
        }, 250);

        break;

      case "linkedin":
        addText(
          "success",
          "Opening LinkedIn..."
        );

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
          createLine("success", "● ONLINE"),
          createLine(
            "output",
            "Portfolio operational"
          ),
          createLine(
            "output",
            "Open to opportunities"
          ),
          createLine(
            "muted",
            "Terminal environment: client-side"
          ),
        ]);
        break;

      case "date":
        addText(
          "output",
          new Date().toString()
        );
        break;

      case "history":
        if (history.length === 0) {
          addText("muted", "No commands in history.");
        } else {
          addLines(
            history.map((entry, index) =>
              createLine(
                "output",
                `  ${String(index + 1).padStart(2, " ")}  ${entry}`
              )
            )
          );
        }
        break;

      case "clear":
      case "cls":
        setLines([]);
        break;

      default:
        addLines([
          createLine(
            "error",
            `command not found: ${command}`
          ),
          createLine(
            "info",
            'Type "help" for available commands.'
          ),
        ]);
        break;
    }
  };

  const handleSubmit = (
    event: React.FormEvent<HTMLFormElement>
  ) => {
    event.preventDefault();

    const command = input.trim();

    if (command) {
      setHistory((previous) => [
        ...previous,
        command,
      ]);
    }

    setHistoryIndex(-1);
    executeCommand(command);
    setInput("");
  };

  const handleKeyDown = (
    event: React.KeyboardEvent<HTMLInputElement>
  ) => {
    if (event.key === "ArrowUp") {
      event.preventDefault();

      if (history.length === 0) return;

      const nextIndex =
        historyIndex === -1
          ? history.length - 1
          : Math.max(0, historyIndex - 1);

      setHistoryIndex(nextIndex);
      setInput(history[nextIndex]);
      return;
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

      return;
    }

    if (event.key === "Tab") {
      event.preventDefault();

      const currentInput = input.toLowerCase();

      const matches = allCommands.filter((command) =>
        command.startsWith(currentInput)
      );

      if (matches.length === 1) {
        setInput(matches[0]);
      } else if (matches.length > 1) {
        addLines([
          createLine("info", "Possible commands:"),
          createLine(
            "output",
            `  ${matches.join("  ")}`
          ),
        ]);
      }

      return;
    }

    if (event.key === "Escape") {
      setInput("");
      setHistoryIndex(-1);
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

    const terminal =
      terminalBodyRef.current;

    terminal?.addEventListener(
      "click",
      focusInput
    );

    return () => {
      terminal?.removeEventListener(
        "click",
        focusInput
      );
    };
  }, []);

  return (
    <div
      className="terminal-window"
      onClick={() => inputRef.current?.focus()}
    >
      <div className="terminal-header">
        <div className="terminal-controls">
          <span className="terminal-dot terminal-dot-red" />
          <span className="terminal-dot terminal-dot-yellow" />
          <span className="terminal-dot terminal-dot-green" />
        </div>

        <div className="terminal-title">
          <span>aymane@portfolio</span>
          <span className="terminal-separator">
            —
          </span>
          <span>zsh</span>
        </div>

        <div className="terminal-header-space" />
      </div>

      <div
        ref={terminalBodyRef}
        className="terminal-body"
        role="log"
        aria-live="polite"
      >
        <div className="terminal-system-line">
          <span className="terminal-green">
            ●
          </span>

          <span>
            {" "}
            Aymane's Portfolio Terminal
          </span>
        </div>

        <div className="terminal-system-line terminal-muted">
          Secure client-side environment · v2.0.0
        </div>

        <div className="terminal-system-line terminal-muted">
          Type "help" to explore the system.
        </div>

        <div className="terminal-divider" />

        {lines.map((line) => (
          <div
            key={line.id}
            className={`terminal-line terminal-line-${line.type}`}
          >
            {line.type === "command" ? (
              <div className="terminal-command">
                <span className="terminal-prompt">
                  aymane@portfolio
                </span>

                <span className="terminal-path">
                  {currentPath}
                </span>

                <span className="terminal-symbol">
                  %
                </span>

                <span className="terminal-command-text">
                  {line.content}
                </span>
              </div>
            ) : (
              <div className="terminal-output">
                {line.content}
              </div>
            )}
          </div>
        ))}

        <form
          className="terminal-command terminal-active-command"
          onSubmit={handleSubmit}
        >
          <span className="terminal-prompt">
            aymane@portfolio
          </span>

          <span className="terminal-path">
            {currentPath}
          </span>

          <span className="terminal-symbol">
            %
          </span>

          <input
            ref={inputRef}
            value={input}
            onChange={(event) =>
              setInput(event.target.value)
            }
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

      <div className="terminal-footer">
        <span>
          <span className="terminal-green">
            ●
          </span>{" "}
          connected
        </span>

        <span>
          ↑ ↓ history&nbsp;&nbsp;·&nbsp;&nbsp;
          TAB autocomplete&nbsp;&nbsp;·&nbsp;&nbsp;
          ENTER run
        </span>
      </div>
    </div>
  );
}

