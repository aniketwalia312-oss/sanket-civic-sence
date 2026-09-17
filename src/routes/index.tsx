import { createFileRoute, Link } from "@tanstack/react-router";
import {
  ArrowRight,
  BadgeCheck,
  BrainCircuit,
  Building2,
  CheckCircle2,
  Files,
  GitMerge,
  Radar,
  ShieldCheck,
  Sparkles,
  Users,
  Workflow,
} from "lucide-react";
import { AppShell } from "@/components/sanket/AppShell";
import { HomeDemoMap } from "@/components/sanket/HomeDemoMap";
import { Button } from "@/components/ui/button";
import civicHero from "@/assets/sanket-civic-hero.jpg";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Sanket — Intelligent Civic Grievance & Resolution Platform" },
      {
        name: "description",
        content:
          "Report civic issues with GPS-verified photos, watch AI validate repairs before and after, and audit municipal work as a community.",
      },
      { property: "og:title", content: "Sanket — Civic grievance, resolved transparently" },
      {
        property: "og:description",
        content: "AI evidence integrity, spatial deduplication and citizen-audited municipal repairs.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: Landing,
});

function Landing() {
  return (
    <AppShell>
      <section className="relative isolate min-h-[620px] overflow-hidden border-b sm:min-h-[680px]">
        <img
          src={civicHero}
          alt="Citizens documenting varied civic issues including a damaged road, leaking pipe, broken streetlight, waste and an unsafe footpath"
          width={1920}
          height={1080}
          className="absolute inset-0 -z-20 h-full w-full object-cover object-center"
        />
        <div className="absolute inset-0 -z-10 bg-gradient-to-r from-background via-background/95 to-background/20" />
        <div className="mx-auto flex min-h-[620px] max-w-6xl items-center px-4 py-16 sm:min-h-[680px]">
          <div className="max-w-xl">
            <span className="inline-flex items-center gap-2 rounded-full border bg-card/90 px-3 py-1.5 text-xs font-medium shadow-sm backdrop-blur">
              <Radar className="h-3.5 w-3.5 text-accent" /> Civic issues, tracked to resolution
            </span>
            <h1 className="mt-5 text-5xl font-semibold sm:text-6xl">Sanket</h1>
            <p className="mt-4 max-w-lg text-xl font-medium leading-snug sm:text-2xl">
              One trusted signal for every civic issue.
            </p>
            <p className="mt-4 max-w-md text-base leading-relaxed text-muted-foreground">
              Report what needs attention. Sanket verifies evidence, connects related reports and keeps every resolution accountable.
            </p>
            <div className="mt-7 flex flex-wrap gap-3">
              <Button asChild size="lg">
                <Link to="/dashboard/citizen">Report an issue</Link>
              </Button>
              <Button asChild size="lg" variant="outline" className="bg-card/90 backdrop-blur">
                <Link to="/auth">Worker / official access</Link>
              </Button>
            </div>
            <div className="mt-7 flex flex-wrap gap-x-5 gap-y-2 text-xs font-medium text-foreground/80">
              <span className="flex items-center gap-1.5"><CheckCircle2 className="h-3.5 w-3.5 text-success" /> Multi-category reporting</span>
              <span className="flex items-center gap-1.5"><CheckCircle2 className="h-3.5 w-3.5 text-success" /> Citizen-verified outcomes</span>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-14 sm:py-18">
        <div className="mb-7 flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <span className="text-xs font-semibold uppercase text-primary">Live civic intelligence</span>
            <h2 className="mt-2 text-2xl font-semibold sm:text-3xl">See what needs attention—at a glance.</h2>
          </div>
          <p className="max-w-md text-sm text-muted-foreground">Explore simulated reports across issue types, locations and resolution stages.</p>
        </div>
        <HomeDemoMap />
      </section>

      <section className="border-y bg-secondary/35">
        <div className="mx-auto grid max-w-6xl gap-4 px-4 py-14 md:grid-cols-2 lg:grid-cols-4">
        <Feature icon={ShieldCheck} title="Evidence Integrity">
          Location and image checks help keep every report trustworthy.
        </Feature>
        <Feature icon={Users} title="Community Aggregation">
          Related reports become one stronger, clearer civic signal.
        </Feature>
        <Feature icon={Workflow} title="Transparent Priority">
          Visible factors turn urgency into a priority anyone can understand.
        </Feature>
        <Feature icon={Radar} title="AI Resolution Audit">
          Before-and-after evidence supports a citizen-verified outcome.
        </Feature>
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-14 sm:py-18">
        <div className="mx-auto mb-8 max-w-xl text-center">
          <span className="text-xs font-semibold uppercase text-primary">Closed-loop accountability</span>
          <h2 className="mt-2 text-2xl font-semibold sm:text-3xl">From signal to verified resolution</h2>
        </div>
        <div className="grid gap-2 sm:grid-cols-2 lg:grid-cols-[1fr_auto_1fr_auto_1fr_auto_1fr_auto_1fr_auto_1fr_auto_1fr] lg:items-center">
          <FlowStep icon={Users} label="Citizen Reports" />
          <FlowArrow />
          <FlowStep icon={BrainCircuit} label="AI Understanding" />
          <FlowArrow />
          <FlowStep icon={BadgeCheck} label="Evidence Check" />
          <FlowArrow />
          <FlowStep icon={GitMerge} label="Related Reports Consolidated" />
          <FlowArrow />
          <FlowStep icon={Sparkles} label="Priority" />
          <FlowArrow />
          <FlowStep icon={Building2} label="Authority Action" />
          <FlowArrow />
          <FlowStep icon={Files} label="Citizen Verification" />
        </div>
      </section>
    </AppShell>
  );
}

function Feature({
  icon: Icon,
  title,
  children,
}: {
  icon: typeof Radar;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <article className="rounded-lg border bg-card p-5 shadow-sm transition-transform duration-200 motion-safe:hover:-translate-y-1">
      <div className="mb-4 flex h-9 w-9 items-center justify-center rounded-md bg-primary/10">
        <Icon className="h-5 w-5 text-primary" />
      </div>
      <h3 className="font-medium">{title}</h3>
      <p className="text-sm text-muted-foreground">{children}</p>
    </article>
  );
}

function FlowStep({ icon: Icon, label }: { icon: typeof Radar; label: string }) {
  return (
    <div className="flex min-h-24 items-center gap-3 rounded-lg border bg-card p-3 shadow-sm lg:flex-col lg:justify-center lg:text-center">
      <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-md bg-secondary text-primary">
        <Icon className="h-4 w-4" />
      </span>
      <span className="text-xs font-medium leading-snug">{label}</span>
    </div>
  );
}

function FlowArrow() {
  return <ArrowRight className="mx-auto hidden h-4 w-4 text-muted-foreground lg:block" aria-hidden="true" />;
}
