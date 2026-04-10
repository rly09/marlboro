import { cn } from '../lib/utils';

export const StatusPill = ({ status, className }) => {
  const getStyles = () => {
    switch (status) {
      case 'Pending':
        return 'bg-red-500/10 text-red-400 border border-red-500/20';
      case 'In Progress':
        return 'bg-orange-500/10 text-orange-400 border border-orange-500/20';
      case 'Cleaned':
        return 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20';
      case 'Low':
        return 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 shadow-[0_0_10px_rgba(16,185,129,0.2)]';
      case 'Medium':
        return 'bg-orange-500/10 text-orange-400 border border-orange-500/20 shadow-[0_0_10px_rgba(249,115,22,0.2)]';
      case 'High':
        return 'bg-red-500/10 text-red-400 border border-red-500/20 shadow-[0_0_10px_rgba(239,68,68,0.2)]';
      default:
        return 'bg-gray-500/10 text-gray-400 border border-gray-500/20';
    }
  };

  return (
    <span className={cn('px-3 py-1 rounded-full text-xs font-medium', getStyles(), className)}>
      {status}
    </span>
  );
};
