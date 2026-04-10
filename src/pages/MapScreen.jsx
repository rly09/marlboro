import { useContext, useState, useEffect, useRef } from 'react';
import { MapContainer, TileLayer, Marker, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { AppContext } from '../context/AppContext';
import { TaskModal } from '../components/TaskModal';
import MarkerClusterGroup from 'react-leaflet-cluster';

// Fix typical Leaflet icon issue
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

// Custom icons based on severity
const createCustomIcon = (color, isPulsing = false) => {
  return L.divIcon({
    className: 'custom-icon',
    html: `
      <div style="
        background-color: ${color};
        width: 24px;
        height: 24px;
        border-radius: 50%;
        border: 2px solid white;
        box-shadow: 0 0 15px ${color};
        ${isPulsing ? 'animation: pulse 2s infinite;' : ''}
      "></div>
    `,
    iconSize: [24, 24],
    iconAnchor: [12, 12],
  });
};

const userIcon = L.divIcon({
  className: 'user-icon',
  html: `
    <div class="relative">
      <div class="absolute -inset-2 bg-blue-500/30 rounded-full animate-ping"></div>
      <div class="relative bg-blue-500 w-4 h-4 rounded-full border-2 border-white shadow-[0_0_10px_rgba(59,130,246,0.8)]"></div>
    </div>
  `,
  iconSize: [16, 16],
  iconAnchor: [8, 8],
});

const iconMap = {
  Low: createCustomIcon('#10b981'),
  Medium: createCustomIcon('#f97316'),
  High: createCustomIcon('#ef4444', true),
};

// Custom cluster icon to match neon styling
const createClusterCustomIcon = function (cluster) {
  const count = cluster.getChildCount();
  return L.divIcon({
    html: `<div class="bg-emerald-500/20 text-emerald-400 font-bold border-2 border-emerald-500 shadow-[0_0_20px_rgba(16,185,129,0.6)] w-12 h-12 rounded-full flex items-center justify-center">${count}</div>`,
    className: 'custom-marker-cluster',
    iconSize: L.point(48, 48, true),
  });
};

const LocationMarker = () => {
  const [position, setPosition] = useState(null);
  const map = useMap();

  useEffect(() => {
    map.locate().on("locationfound", function (e) {
      setPosition(e.latlng);
      map.flyTo(e.latlng, map.getZoom());
    });
  }, [map]);

  return position === null ? null : (
    <Marker position={position} icon={userIcon} />
  );
};

// Fly to a newly added report so it immediately appears on screen
const FlyToLatestReport = ({ reports }) => {
  const map = useMap();
  const prevLen = useRef(reports.length);

  useEffect(() => {
    if (reports.length > prevLen.current) {
      const latest = reports[reports.length - 1];
      if (latest?.lat && latest?.lng) {
        map.flyTo([latest.lat, latest.lng], 17, { duration: 1.5 });
      }
    }
    prevLen.current = reports.length;
  }, [reports, map]);

  return null;
};

export const MapScreen = () => {
  const { reports } = useContext(AppContext);
  const [selectedReport, setSelectedReport] = useState(null);

  return (
    <div className="relative w-full h-screen bg-background">
      {/* Top Header Blur effect */}
      <div className="absolute top-0 inset-x-0 h-24 bg-gradient-to-b from-black/80 to-transparent z-[400] pointer-events-none flex items-start justify-center pt-6">
        <h1 className="text-2xl font-semibold text-white tracking-tight drop-shadow-md">CleanCity AI</h1>
      </div>

      <MapContainer 
        center={[12.8231, 80.0444]} 
        zoom={16} 
        className="w-full h-full"
        zoomControl={false}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
          url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        />
        
        <LocationMarker />
        <FlyToLatestReport reports={reports} />

        <MarkerClusterGroup
          chunkedLoading
          iconCreateFunction={createClusterCustomIcon}
          maxClusterRadius={50}
        >
          {reports.filter(report => report.status !== 'Cleaned').map((report) => (
            <Marker 
              key={report.id} 
              position={[report.lat, report.lng]}
              icon={iconMap[report.severity]}
              eventHandlers={{
                click: () => setSelectedReport(report),
              }}
            />
          ))}
        </MarkerClusterGroup>
      </MapContainer>

      <TaskModal 
        report={selectedReport} 
        onClose={() => setSelectedReport(null)} 
      />
    </div>
  );
};
