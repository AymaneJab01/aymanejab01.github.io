import React, { useEffect, useRef, useState } from "react";

type TerminalLine = {
  type: "command" | "output" | "success" | "error" | "info";
  content: string;
};

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
  "movie",
  "notes",
  "education",
  "contact",
  "github",
  "linkedin",
  "status",
  "clear",
];

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

  const executeCommand = (rawCommand: string) => {
    const command = rawCommand.trim().toLowerCase();

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

    switch (command) {
      case "help":
        addLines([
          {
            type: "output",
            content: "Available commands:",
          },
          {
            type: "output",
            content: "  about       → Learn more about me",
          },
          {
            type: "output",
            content: "  whoami      → Display developer information",
          },
          {
            type: "output",
            content: "  skills      → View technologies and skills",
          },
          {
            type: "output",
            content: "  projects    → Jump to my projects",
          },
          {
            type: "output",
            content: "  movie       → Open movie ranking",
          },
          {
            type: "output",
            content: "  notes       → Open my study notes",
          },
          {
            type: "output",
            content: "  education   → View my computer science background",
          },
          {
            type: "output",
            content: "  contact     → Get in touch",
          },
          {
            type: "output",
            content: "  github      → Open GitHub",
          },
          {
            type: "output",
            content: "  linkedin    → Open LinkedIn",
          },
          {
            type: "output",
            content: "  status      → Check current availability",
          },
          {
            type: "output",
            content: "  clear       → Clear the terminal",
          },
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
        addLines([
          {
            type: "output",
            content: "Navigating to projects...",
          },
        ]);

        setTimeout(() => {
          document
            .getElementById("projects")
            ?.scrollIntoView({ behavior: "smooth" });
        }, 150);
        break;

      case "movie":
        addLines([
          {
            type: "success",
            content: "Opening Movie Ranking...",
          },
        ]);

        setTimeout(() => {
          window.location.href = "/projects/movie-ranking";
        }, 250);
        break;

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
              <div className="terminal-output">
                {line.content}
              </div>
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