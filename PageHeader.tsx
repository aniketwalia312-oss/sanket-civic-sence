import { cn } from "@/lib/utils";

/**
 * Compact branded header used at the top of interior pages.
 * Mirrors the homepage hero's visual language (eyebrow pill + icon,
 * gradient tint) so every screen in the app reads as one product,
 * without repeating the homepage photo.
 */
export function PageHeader({
  icon: Icon,
  eyebrow,
  title,
  description,
  actions,
  className,
}: {
  icon: React.ComponentType<{ className?: string }>;
  eyebrow: string;
  title: string;
  description?: React.ReactNode;
  actions?: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-xl border bg-gradient-to-r from-secondary/70 via-secondary/25 to-transparent px-5 py-6 sm:px-7 sm:py-7",
        className,
      )}
    >
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <span className="inline-flex items-center gap-2 rounded-full border bg-card/90 px-3 py-1 text-xs font-medium shadow-sm backdrop-blur">
            <Icon className="h-3.5 w-3.5 text-accent" /> {eyebrow}
          </span>
          <h1 className="mt-3 text-2xl font-semibold tracking-tight sm:text-3xl">{title}</h1>
          {description && <p className="mt-1.5 max-w-xl text-sm text-muted-foreground">{description}</p>}
        </div>
        {actions && <div className="flex shrink-0 flex-wrap items-center gap-2">{actions}</div>}
      </div>
    </div>
  );
}
