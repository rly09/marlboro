import { cn } from '../lib/utils';
import { motion } from 'framer-motion';

export const GlassCard = ({ children, className, ...props }) => {
  return (
    <motion.div
      className={cn("bg-black/20 backdrop-blur-md border border-white/10 rounded-3xl p-4 transition-all duration-300 ease-out hover:shadow-xl", className)}
      {...props}
    >
      {children}
    </motion.div>
  );
};
