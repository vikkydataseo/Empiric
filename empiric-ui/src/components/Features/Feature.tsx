import React, { ReactNode } from "react";

export interface BulletPoint {
  title: string;
  description: string | ReactNode;
}

interface FeatureProps {
  title: string;
  bulletPoints: BulletPoint[];
}

const Feature: React.FC<FeatureProps> = ({ title, bulletPoints }) => (
  <div>
    <h3 className="text-2xl font-medium tracking-tight text-slate-900 sm:text-3xl">
      {title}
    </h3>
    <div className="prose prose-slate mt-8 space-y-6 lg:mt-10 lg:space-y-8 lg:prose-xl">
      {bulletPoints.map(({ title, description }) => (
        <p key={title}>
          <strong>{title}.</strong> {description}
        </p>
      ))}
    </div>
  </div>
);

export default Feature;
