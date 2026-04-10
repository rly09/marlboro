import { useState, useContext, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Camera, X, UploadCloud, MapPin, Sparkles } from 'lucide-react';
import { GlassCard } from './GlassCard';
import { StatusPill } from './StatusPill';
import { AppContext } from '../context/AppContext';
import { cn } from '../lib/utils';

export const ReportModal = ({ isOpen, onClose }) => {
  const { addReport } = useContext(AppContext);
  const [step, setStep] = useState(1);
  const [imagePreview, setImagePreview] = useState(null);
  const [file, setFile] = useState(null);
  const [severity, setSeverity] = useState('Medium');
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [coords, setCoords] = useState({ lat: 51.5, lng: -0.1 }); // Default fallback
  const fileInputRef = useRef(null);

  const captureLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setCoords({
            lat: position.coords.latitude,
            lng: position.coords.longitude
          });
        },
        (error) => console.error("Error getting location:", error),
        { enableHighAccuracy: true }
      );
    }
  };

  const handleImageUpload = (e) => {
    const selectedFile = e.target.files[0];
    if (!selectedFile) return;

    setFile(selectedFile);
    setImagePreview(URL.createObjectURL(selectedFile));
    setIsAnalyzing(true);
    captureLocation();

    // Simulate AI delay
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
      description: 'User reported waste',
      aiInsight: severity === 'High' ? 'Waste detected - High priority' : 'General waste report'
    });
    onClose();
    setTimeout(() => {
      setStep(1);
      setImagePreview(null);
      setFile(null);
      setSeverity('Medium');
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
            className="relative w-full max-w-md"
          >
            <GlassCard className="p-6 relative bg-black/40">
              <button 
                onClick={onClose}
                className="absolute top-4 right-4 text-white/50 hover:text-white transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
              
              <h2 className="text-xl font-semibold text-white mb-6">Report Garbage</h2>

              {step === 1 ? (
                <div 
                  className={cn(
                    "border-2 border-dashed rounded-2xl p-8 flex flex-col items-center justify-center text-center cursor-pointer transition-all duration-300",
                    isAnalyzing ? "border-emerald-500/50 bg-emerald-500/5" : "border-white/20 hover:border-emerald-400/50 hover:bg-white/5"
                  )}
                  onClick={() => fileInputRef.current?.click()}
                >
                  <input
                    type="file"
                    ref={fileInputRef}
                    className="hidden"
                    accept="image/*"
                    capture="environment"
                    onChange={handleImageUpload}
                  />
                  {isAnalyzing ? (
                    <>
                      <Sparkles className="w-12 h-12 text-emerald-400 mb-4 animate-pulse" />
                      <p className="text-emerald-400 font-medium">AI Analyzing Image...</p>
                    </>
                  ) : (
                    <>
                      <UploadCloud className="w-12 h-12 text-white/50 mb-4 group-hover:text-emerald-400 transition-colors" />
                      <p className="text-white/80 font-medium mb-1">Click to Capture/Upload</p>
                      <p className="text-white/50 text-sm">Real-time GPS acquisition</p>
                    </>
                  )}
                </div>
              ) : (
                <div className="space-y-6">
                  <div className="relative rounded-xl overflow-hidden h-40">
                    <img src={imagePreview} alt="Uploaded" className="w-full h-full object-cover" />
                    <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 to-transparent p-3">
                      <div className="flex items-center gap-2">
                        <Sparkles className="w-4 h-4 text-emerald-400" />
                        <span className="text-xs text-emerald-400 font-medium bg-emerald-500/10 px-2 py-1 rounded-full backdrop-blur-md">
                          Plastic waste detected
                        </span>
                      </div>
                    </div>
                  </div>

                  <div>
                    <p className="text-sm text-white/70 mb-3">Detected Severity</p>
                    <div className="flex gap-3">
                      {['Low', 'Medium', 'High'].map(s => (
                        <button
                          key={s}
                          onClick={() => setSeverity(s)}
                          className={cn(
                            "flex-1 py-2 rounded-xl text-sm font-medium transition-all duration-300 border",
                            severity === s 
                              ? s === 'Low' ? "bg-emerald-500/20 text-emerald-400 border-emerald-500/50 shadow-[0_0_15px_rgba(16,185,129,0.3)]"
                                : s === 'Medium' ? "bg-orange-500/20 text-orange-400 border-orange-500/50 shadow-[0_0_15px_rgba(249,115,22,0.3)]"
                                : "bg-red-500/20 text-red-400 border-red-500/50 shadow-[0_0_15px_rgba(239,68,68,0.3)]"
                              : "bg-white/5 text-white/50 border-white/10 hover:bg-white/10"
                          )}
                        >
                          {s}
                        </button>
                      ))}
                    </div>
                  </div>

                  <div className="flex items-center gap-3 bg-white/5 p-3 rounded-xl border border-white/10">
                    <MapPin className="w-5 h-5 text-blue-400" />
                    <div>
                      <p className="text-sm font-medium text-white/90">Current Location</p>
                      <p className="text-xs text-white/50">Coordinates acquired</p>
                    </div>
                  </div>

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
