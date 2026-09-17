import { useEffect, useRef, useState } from "react";
import { AlertTriangle, CheckCircle2, MapPin } from "lucide-react";
import { cn } from "@/lib/utils";

type DemoStatus = "Critical" | "High" | "Standard" | "Resolved";

type DemoIncident = {
  id: string;
  title: string;
  category: string;
  location: string;
  latitude: number;
  longitude: number;
  status: DemoStatus;
  priority: number;
};

const DEMO_INCIDENTS: DemoIncident[] = [
  {
    id: "demo-1",
    title: "Unsafe electrical junction",
    category: "Public safety",
    location: "Delhi",
    latitude: 28.6139,
    longitude: 77.209,
    status: "Critical",
    priority: 14.8,
  },
  {
    id: "demo-2",
    title: "Water pipeline leakage",
    category: "Water infrastructure",
    location: "Mumbai",
    latitude: 19.076,
    longitude: 72.8777,
    status: "High",
    priority: 9.6,
  },
  {
    id: "demo-3",
    title: "Broken pedestrian signal",
    category: "Road safety",
    location: "Bengaluru",
    latitude: 12.9716,
    longitude: 77.5946,
    status: "Standard",
    priority: 5.1,
  },
  {
    id: "demo-4",
    title: "Accessible ramp repaired",
    category: "Accessibility",
    location: "Chennai",
    latitude: 13.0827,
    longitude: 80.2707,
    status: "Resolved",
    priority: 3.2,
  },
  {
    id: "demo-5",
    title: "Overflowing public waste point",
    category: "Waste management",
    location: "Hyderabad",
    latitude: 17.385,
    longitude: 78.4867,
    status: "High",
    priority: 8.4,
  },
  {
    id: "demo-6",
    title: "Streetlight network outage",
    category: "Public lighting",
    location: "Kolkata",
    latitude: 22.5726,
    longitude: 88.3639,
    status: "Standard",
    priority: 4.7,
  },
];

const STATUS_TOKEN: Record<DemoStatus, string> = {
  Critical: "--destructive",
  High: "--warning",
  Standard: "--info",
  Resolved: "--success",
};

const STATUS_CLASS: Record<DemoStatus, string> = {
  Critical: "bg-destructive",
  High: "bg-warning",
  Standard: "bg-info",
  Resolved: "bg-success",
};

type GoogleMapsApi = {
  Map: new (element: HTMLElement, options: Record<string, unknown>) => {
    fitBounds: (bounds: unknown, padding?: number) => void;
  };
  Marker: new (options: Record<string, unknown>) => {
    addListener: (event: string, handler: () => void) => void;
  };
  InfoWindow: new () => {
    setContent: (content: string) => void;
    open: (options: Record<string, unknown>) => void;
  };
  LatLngBounds: new () => {
    extend: (position: { lat: number; lng: number }) => void;
  };
  SymbolPath: { CIRCLE: unknown };
};

declare global {
  interface Window {
    google?: { maps: GoogleMapsApi };
    initSanketHomepageMap?: () => void;
  }
}

const MAP_SCRIPT_ID = "sanket-google-maps-script";

export function HomeDemoMap({ className }: { className?: string }) {
  const mapElement = useRef<HTMLDivElement>(null);
  const initialized = useRef(false);
  const [loadError, setLoadError] = useState(false);

  useEffect(() => {
    const apiKey = import.meta.env.VITE_LOVABLE_CONNECTOR_GOOGLE_MAPS_BROWSER_KEY;
    const trackingId = import.meta.env.VITE_LOVABLE_CONNECTOR_GOOGLE_MAPS_TRACKING_ID;

    const initializeMap = () => {
      if (initialized.current || !mapElement.current || !window.google?.maps) return;
      initialized.current = true;

      const maps = window.google.maps;
      const map = new maps.Map(mapElement.current, {
        center: { lat: 21.15, lng: 79.09 },
        zoom: 5,
        clickableIcons: false,
        fullscreenControl: false,
        mapTypeControl: false,
        streetViewControl: false,
        styles: [{ featureType: "poi", stylers: [{ visibility: "off" }] }],
      });
      const infoWindow = new maps.InfoWindow();
      const bounds = new maps.LatLngBounds();
      const rootStyles = getComputedStyle(document.documentElement);

      DEMO_INCIDENTS.forEach((incident) => {
        const position = { lat: incident.latitude, lng: incident.longitude };
        const fillColor = rootStyles.getPropertyValue(STATUS_TOKEN[incident.status]).trim();
        const marker = new maps.Marker({
          map,
          position,
          title: `${incident.title} — DEMO / SIMULATED DATA`,
          icon: {
            path: maps.SymbolPath.CIRCLE,
            fillColor,
            fillOpacity: 1,
            strokeColor: rootStyles.getPropertyValue("--card").trim(),
            strokeOpacity: 1,
            strokeWeight: 3,
            scale: incident.status === "Critical" ? 10 : 8,
          },
        });

        marker.addListener("click", () => {
          infoWindow.setContent(
            `<div style="max-width:220px;font-family:system-ui,sans-serif;color:#183b3b;padding:4px 2px">
              <strong style="display:block;margin-bottom:4px">${incident.title}</strong>
              <span style="font-size:12px">${incident.category} · ${incident.location}</span><br />
              <span style="font-size:12px">${incident.status} · Priority ${incident.priority}</span><br />
              <b style="display:block;margin-top:7px;font-size:10px;letter-spacing:.04em">DEMO / SIMULATED DATA</b>
            </div>`,
          );
          infoWindow.open({ map, anchor: marker });
        });
        bounds.extend(position);
      });

      map.fitBounds(bounds, 48);
    };

    if (!apiKey) {
      setLoadError(true);
      return;
    }

    if (window.google?.maps) {
      initializeMap();
      return;
    }

    window.initSanketHomepageMap = initializeMap;
    const existingScript = document.getElementById(MAP_SCRIPT_ID) as HTMLScriptElement | null;
    if (existingScript) {
      existingScript.addEventListener("error", () => setLoadError(true), { once: true });
      return;
    }

    const script = document.createElement("script");
    script.id = MAP_SCRIPT_ID;
    script.async = true;
    script.src = `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(apiKey)}&loading=async&callback=initSanketHomepageMap&channel=${encodeURIComponent(trackingId ?? "sanket-homepage")}`;
    script.onerror = () => setLoadError(true);
    document.head.appendChild(script);

    return () => {
      if (window.initSanketHomepageMap === initializeMap) delete window.initSanketHomepageMap;
    };
  }, []);

  return (
    <section className={cn("overflow-hidden rounded-lg border bg-card shadow-sm", className)} aria-label="Simulated civic issues map">
      <div className="flex flex-col gap-3 border-b bg-card px-4 py-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <MapPin className="h-4 w-4 text-primary" />
            <h2 className="font-semibold">Civic issue command map</h2>
          </div>
          <p className="mt-1 text-xs text-muted-foreground">A cross-category view of reports, priorities and outcomes.</p>
        </div>
        <span className="inline-flex w-fit items-center rounded-full border border-warning/40 bg-warning/15 px-2.5 py-1 text-[11px] font-semibold text-warning-foreground">
          DEMO / SIMULATED DATA
        </span>
      </div>

      <div className="relative h-[390px] w-full sm:h-[470px]">
        <div ref={mapElement} className="h-full w-full" />
        {loadError && (
          <div className="absolute inset-0 flex items-center justify-center bg-secondary p-6 text-center">
            <div className="max-w-xs">
              <AlertTriangle className="mx-auto h-6 w-6 text-warning" />
              <p className="mt-2 text-sm font-medium">The live map is temporarily unavailable.</p>
              <p className="mt-1 text-xs text-muted-foreground">Demo incident details remain available in the legend below.</p>
            </div>
          </div>
        )}
      </div>

      <div className="flex flex-wrap gap-x-5 gap-y-2 border-t bg-card px-4 py-3 text-xs text-muted-foreground">
        {(Object.keys(STATUS_CLASS) as DemoStatus[]).map((status) => (
          <span key={status} className="flex items-center gap-1.5">
            <i className={cn("h-2.5 w-2.5 rounded-full", STATUS_CLASS[status])} /> {status}
          </span>
        ))}
        <span className="ml-auto hidden items-center gap-1 text-success sm:flex">
          <CheckCircle2 className="h-3.5 w-3.5" /> Interactive markers
        </span>
      </div>
    </section>
  );
}