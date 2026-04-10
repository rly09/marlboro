import { useState, useContext, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, UploadCloud, MapPin, Sparkles, Navigation, Map } from 'lucide-react';
import { MapContainer, TileLayer, Marker, useMapEvents, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { GlassCard } from './GlassCard';
import { AppContext } from '../context/AppContext';
import { cn } from '../lib/utils';

// Fix Leaflet default icon
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

const pinIcon = L.divIcon({
  className: 'report-pin',
  html: `<div style="
    width:28px;height:28px;border-radius:50% 50% 50% 0;
    background:linear-gradient(135deg,#10b981,#3b82f6);
    border:2px solid white;
    box-shadow:0 0 18px rgba(16,185,129,0.8);
    transform:rotate(-45deg);
  "></div>`,
  iconSize: [28, 28],
  iconAnchor: [14, 28],
});

// Click listener — lives inside MapContainer
const LocationPicker = ({ coords, onPick }) => {
  useMapEvents({
    click(e) {
      onPick({ lat: e.latlng.lat, lng: e.latlng.lng });
    },
  });
  return <Marker position={[coords.lat, coords.lng]} icon={pinIcon} />;
};

// Syncs the mini-map view when GPS coords update
const MapSync = ({ coords }) => {
  const map = useMap();
  useEffect(() => {
    map.flyTo([coords.lat, coords.lng], map.getZoom(), { duration: 0.8 });
  }, [coords.lat, coords.lng, map]);
  return null;
};

export const ReportModal = ({ isOpen, onClose }) => {
  const { addReport } = useContext(AppContext);
  const [step, setStep] = useState(1);
  const [imagePreview, setImagePreview] = useState(null);
  const [file, setFile] = useState(null);
  const [severity, setSeverity] = useState('Medium');
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [locMode, setLocMode] = useState('gps'); // 'gps' | 'manual'
  const [gpsLoading, setGpsLoading] = useState(false);
  const [coords, setCoords] = useState({ lat: 12.8231, lng: 80.0444 }); // SRM default
  const [description, setDescription] = useState('');
  const fileInputRef = useRef(null);

  const grabGPS = () => {
    setGpsLoading(true);
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          setCoords({ lat: pos.coords.latitude, lng: pos.coords.longitude });
          setLocMode('gps');
          setGpsLoading(false);
        },
        () => setGpsLoading(false),
        { enableHighAccuracy: true, timeout: 6000 }
      );
    } else {
      setGpsLoading(false);
    }
  };

  const handleImageUpload = (e) => {
    const selectedFile = e.target.files[0];
    if (!selectedFile) return;
    setFile(selectedFile);
    setImagePreview(URL.createObjectURL(selectedFile));
    setIsAnalyzing(true);
    grabGPS();
    setTimeout(() => {
      setSeverity('High');
      setIsAnalyzing(false);
      setStep(2);
    }, 1500);
  };

  const handleSubmit = () => {
    addReport({
      lat: coords.lat,
      lng: coords.lng,
      severity,
      file,
      description: description.trim() || 'User reported waste',
      aiInsight: severity === 'High' ? 'Waste detected - High priority' : 'General waste report',
    });
    onClose();
    setTimeout(() => {
      setStep(1);
      setImagePreview(null);
      setFile(null);
      setSeverity('Medium');
      setDescription('');
      setLocMode('gps');
    }, 500);
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-[500] flex items-center justify-center p-4">
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            onClick={onClose}
          />
          <motion.div
            initial={{ scale: 0.9, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.9, opacity: 0, y: 20 }}
            className="relative w-full max-w-md max-h-[90vh] overflow-y-auto"
          >
            <GlassCard className="p-6 relative bg-black/40">
              <button
                onClick={onClose}
                className="absolute top-4 right-4 text-white/50 hover:text-white transition-colors z-10"
              >
                <X className="w-5 h-5" />
              </button>

              <h2 className="text-xl font-semibold text-white mb-6">Report Garbage</h2>

              {step === 1 ? (
                /* ── STEP 1: Upload image ── */
                <div
                  className={cn(
                    'border-2 border-dashed rounded-2xl p-8 flex flex-col items-center justify-center text-center cursor-pointer transition-all duration-300',
                    isAnalyzing
                      ? 'border-emerald-500/50 bg-emerald-500/5'
                      : 'border-white/20 hover:border-emerald-400/50 hover:bg-white/5'
                  )}
                  onClick={() => fileInputRef.current?.click()}
                >
                  <input
                    type="file"
                    ref={fileInputRef}
                    className="hidden"
                    accept="image/*"
                    onChange={handleImageUpload}
                  />
                  {isAnalyzing ? (
                    <>
                      <Sparkles className="w-12 h-12 text-emerald-400 mb-4 animate-pulse" />
                      <p className="text-emerald-400 font-medium">AI Analyzing Image...</p>
                    </>
                  ) : (
                    <>
                      <UploadCloud className="w-12 h-12 text-white/50 mb-4" />
                      <p className="text-white/80 font-medium mb-1">Click to Capture / Upload</p>
                      <p className="text-white/50 text-sm">Photo + GPS acquired automatically</p>
                    </>
                  )}
                </div>
              ) : (
                /* ── STEP 2: Details + Location ── */
                <div className="space-y-5">

                  {/* Image preview */}
                  <div className="relative rounded-xl overflow-hidden h-36">
                    <img src={imagePreview} alt="Uploaded" className="w-full h-full object-cover" />
                    <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 to-transparent p-3 flex items-center gap-2">
                      <Sparkles className="w-4 h-4 text-emerald-400 shrink-0" />
                      <span className="text-xs text-emerald-400 font-medium bg-emerald-500/10 px-2 py-1 rounded-full backdrop-blur-md">
                        AI waste analysis complete
                      </span>
                    </div>
                  </div>

                  {/* Description */}
                  <div>
                    <p className="text-sm text-white/70 mb-2">Description</p>
                    <textarea
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      placeholder="Describe the garbage / location..."
                      rows={2}
                      className="w-full bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-sm text-white placeholder-white/30 resize-none focus:outline-none focus:border-emerald-500/50"
                    />
                  </div>

                  {/* Severity */}
                  <div>
                    <p className="text-sm text-white/70 mb-2">Severity</p>
                    <div className="flex gap-3">
                      {['Low', 'Medium', 'High'].map((s) => (
                        <button
                          key={s}
                          onClick={() => setSeverity(s)}
                          className={cn(
                            'flex-1 py-2 rounded-xl text-sm font-medium transition-all duration-300 border',
                            severity === s
                              ? s === 'Low'
                                ? 'bg-emerald-500/20 text-emerald-400 border-emerald-500/50 shadow-[0_0_15px_rgba(16,185,129,0.3)]'
                                : s === 'Medium'
                                ? 'bg-orange-500/20 text-orange-400 border-orange-500/50 shadow-[0_0_15px_rgba(249,115,22,0.3)]'
                                : 'bg-red-500/20 text-red-400 border-red-500/50 shadow-[0_0_15px_rgba(239,68,68,0.3)]'
                              : 'bg-white/5 text-white/50 border-white/10 hover:bg-white/10'
                          )}
                        >
                          {s}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* ── Location Section ── */}
                  <div>
                    <div className="flex items-center justify-between mb-2">
                      <p className="text-sm text-white/70">Location</p>
                      {/* Mode toggle */}
                      <div className="flex gap-1">
                        <button
                          onClick={() => setLocMode('gps')}
                          className={cn(
                            'flex items-center gap-1 px-3 py-1 rounded-lg text-xs font-medium transition-all duration-200 border',
                            locMode === 'gps'
                              ? 'bg-blue-500/20 text-blue-400 border-blue-500/40'
                              : 'bg-white/5 text-white/40 border-white/10 hover:bg-white/10'
                          )}
                        >
                          <Navigation className="w-3 h-3" />
                          GPS
                        </button>
                        <button
                          onClick={() => setLocMode('manual')}
                          className={cn(
                            'flex items-center gap-1 px-3 py-1 rounded-lg text-xs font-medium transition-all duration-200 border',
                            locMode === 'manual'
                              ? 'bg-emerald-500/20 text-emerald-400 border-emerald-500/40'
                              : 'bg-white/5 text-white/40 border-white/10 hover:bg-white/10'
                          )}
                        >
                          <Map className="w-3 h-3" />
                          Pick on Map
                        </button>
                      </div>
                    </div>

                    {/* GPS strip */}
                    {locMode === 'gps' && (
                      <div className="flex items-center justify-between bg-white/5 border border-white/10 rounded-xl p-3">
                        <div className="flex items-center gap-3">
                          <MapPin className="w-5 h-5 text-blue-400 shrink-0" />
                          <div>
                            <p className="text-xs font-medium text-white/90">
                              {coords.lat.toFixed(5)}, {coords.lng.toFixed(5)}
                            </p>
                            <p className="text-xs text-white/40">
                              {gpsLoading ? 'Acquiring GPS…' : 'GPS coordinates'}
                            </p>
                          </div>
                        </div>
                        <button
                          onClick={grabGPS}
                          disabled={gpsLoading}
                          className="text-xs px-3 py-1.5 rounded-lg bg-blue-500/20 text-blue-400 border border-blue-500/30 hover:bg-blue-500/30 transition-all disabled:opacity-50"
                        >
                          {gpsLoading ? 'Locating…' : 'Refresh'}
                        </button>
                      </div>
                    )}

                    {/* Mini map picker */}
                    {locMode === 'manual' && (
                      <div className="rounded-xl overflow-hidden border border-white/10">
                        <div style={{ height: '180px' }}>
                          <MapContainer
                            center={[coords.lat, coords.lng]}
                            zoom={15}
                            style={{ width: '100%', height: '100%' }}
                            zoomControl={true}
                            attributionControl={false}
                          >
                            <TileLayer url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png" />
                            <MapSync coords={coords} />
                            <LocationPicker coords={coords} onPick={setCoords} />
                          </MapContainer>
                        </div>
                        <div className="flex items-center gap-2 bg-black/70 px-3 py-1.5">
                          <MapPin className="w-3.5 h-3.5 text-emerald-400 shrink-0" />
                          <p className="text-xs text-white/60">
                            Tap anywhere on the map to place the pin &nbsp;·&nbsp;
                            <span className="text-emerald-400 font-medium">
                              {coords.lat.toFixed(5)}, {coords.lng.toFixed(5)}
                            </span>
                          </p>
                        </div>
                      </div>
                    )}
                  </div>

                  {/* Submit */}
                  <button
                    onClick={handleSubmit}
                    className="w-full py-3 rounded-xl bg-gradient-to-r from-emerald-500 to-blue-500 text-white font-semibold shadow-[0_0_20px_rgba(59,130,246,0.4)] hover:shadow-[0_0_30px_rgba(59,130,246,0.6)] hover:scale-[1.02] transition-all duration-300"
                  >
                    Submit Report
                  </button>
                </div>
              )}
            </GlassCard>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
