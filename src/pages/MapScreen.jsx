import { useContext, useState } from 'react';
import { MapContainer, TileLayer, Marker, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { AppContext } from '../context/AppContext';
import { TaskModal } from '../components/TaskModal';

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

const iconMap = {
  Low: createCustomIcon('#10b981'),
  Medium: createCustomIcon('#f97316'),
  High: createCustomIcon('#ef4444', true),
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
        center={[51.505, -0.09]} 
        zoom={13} 
        className="w-full h-full"
        zoomControl={false}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
          url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        />
        
        {reports.map((report) => (
          <Marker 
            key={report.id} 
            position={[report.lat, report.lng]}
            icon={iconMap[report.severity]}
            eventHandlers={{
              click: () => setSelectedReport(report),
            }}
          />
        ))}
      </MapContainer>

      <TaskModal 
        report={selectedReport} 
        onClose={() => setSelectedReport(null)} 
      />
    </div>
  );
};
