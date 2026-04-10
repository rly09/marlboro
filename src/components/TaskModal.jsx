import { useContext, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, MapPin, AlertTriangle, Sparkles, CheckCircle2 } from 'lucide-react';
import { GlassCard } from './GlassCard';
import { StatusPill } from './StatusPill';
import { AppContext } from '../context/AppContext';
import confetti from 'canvas-confetti';

export const TaskModal = ({ report, onClose }) => {
  const { claimReport, completeReport } = useContext(AppContext);
  const [isClaiming, setIsClaiming] = useState(false);

  if (!report) return null;

  const handleClaim = () => {
    setIsClaiming(true);
    setTimeout(() => {
      claimReport(report.id);
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 },
        colors: ['#10b981', '#3b82f6', '#ffffff']
      });
      setIsClaiming(false);
      onClose();
    }, 800);
  };

  const handleComplete = () => {
    completeReport(report.id);
    confetti({
      particleCount: 150,
      spread: 100,
      origin: { y: 0.5 },
      colors: ['#10b981', '#fbbf24', '#ffffff']
    });
    onClose();
  };

  return (
    <AnimatePresence>
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
          <GlassCard className="p-0 overflow-hidden bg-black/40">
            <button 
              onClick={onClose}
              className="absolute top-4 right-4 z-10 text-white hover:text-white bg-black/40 p-1 rounded-full backdrop-blur-md transition-colors"
            >
              <X className="w-5 h-5" />
            </button>

            <div className="relative h-48">
              <img src={report.img} alt="Waste location" className="w-full h-full object-cover" />
              <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/90 to-transparent p-4 flex justify-between items-end">
                <StatusPill status={report.status} />
                <StatusPill status={report.severity} />
              </div>
            </div>

            <div className="p-6 space-y-4">
              {report.aiInsight && (
                <div className="flex items-start gap-3 bg-emerald-500/10 border border-emerald-500/20 p-3 rounded-xl">
                  <Sparkles className="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
                  <div>
                    <p className="text-sm font-medium text-emerald-400">AI Insight</p>
                    <p className="text-xs text-emerald-400/80">{report.aiInsight}</p>
                  </div>
                </div>
              )}

              <div className="flex gap-4 border-b border-white/10 pb-4">
                <div className="flex items-center gap-2 flex-1">
                  <MapPin className="w-4 h-4 text-blue-400" />
                  <span className="text-sm text-white/80 line-clamp-1">{report.lat.toFixed(4)}, {report.lng.toFixed(4)}</span>
                </div>
                <div className="flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 text-orange-400" />
                  <span className="text-sm text-white/80">{report.severity} Priority</span>
                </div>
              </div>

              <p className="text-sm text-white/70">{report.description}</p>

              {report.status === 'Pending' && (
                <button
                  onClick={handleClaim}
                  disabled={isClaiming}
                  className="w-full py-3 mt-4 rounded-xl bg-gradient-to-r from-emerald-500 to-blue-500 text-white font-semibold shadow-[0_0_20px_rgba(16,185,129,0.4)] hover:shadow-[0_0_30px_rgba(16,185,129,0.6)] hover:scale-[1.02] transition-all duration-300 flex items-center justify-center gap-2"
                >
                  {isClaiming ? (
                    <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1, ease: "linear" }}>
                      <Sparkles className="w-5 h-5" />
                    </motion.div>
                  ) : (
                    "Claim Cleanup Task"
                  )}
                </button>
              )}

              {report.status === 'In Progress' && (
                <button
                  onClick={handleComplete}
                  className="w-full py-3 mt-4 rounded-xl bg-emerald-500/20 border border-emerald-500 text-emerald-400 font-semibold shadow-[0_0_20px_rgba(16,185,129,0.2)] hover:bg-emerald-500/30 transition-all duration-300 flex items-center justify-center gap-2"
                >
                  <CheckCircle2 className="w-5 h-5" />
                  Mark as Cleaned
                </button>
              )}

            </div>
          </GlassCard>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};
