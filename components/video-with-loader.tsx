"use client"

import { useEffect, useRef, useState } from "react"

interface VideoWithLoaderProps {
  src: string | string[]
  poster?: string
  className?: string
  autoPlay?: boolean
  loop?: boolean
  muted?: boolean
  playsInline?: boolean
  controls?: boolean
  preload?: "none" | "metadata" | "auto"
  onLoaded?: () => void
}

export default function VideoWithLoader({
  src,
  poster,
  className = "",
  autoPlay = false,
  loop = false,
  muted = false,
  playsInline = true,
  controls = false,
  preload = "metadata",
  onLoaded,
}: VideoWithLoaderProps) {
  const videoRef = useRef<HTMLVideoElement>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)

  useEffect(() => {
    const video = videoRef.current
    if (!video) return

    const handleCanPlay = () => {
      setIsLoading(false)
      if (onLoaded) onLoaded()
    }

    const handleError = () => {
      setIsLoading(false)
      setHasError(true)
    }

    const handleLoadStart = () => {
      setIsLoading(true)
    }

    video.addEventListener('canplay', handleCanPlay, { once: true })
    video.addEventListener('error', handleError, { once: true })
    video.addEventListener('loadstart', handleLoadStart)

    return () => {
      video.removeEventListener('canplay', handleCanPlay)
      video.removeEventListener('error', handleError)
      video.removeEventListener('loadstart', handleLoadStart)
    }
  }, [onLoaded])

  const sources = Array.isArray(src) ? src : [src]

  return (
    <div className={`relative ${className}`}>
      {/* Video Element */}
      <video
        ref={videoRef}
        autoPlay={autoPlay}
        loop={loop}
        muted={muted}
        playsInline={playsInline}
        controls={controls}
        preload={preload}
        poster={poster}
        className="w-full h-full object-cover"
        style={{ opacity: isLoading && !poster ? 0 : 1 }}
      >
        {sources.map((source, index) => (
          <source key={index} src={source} type="video/mp4" />
        ))}
      </video>

      {/* Loading Spinner */}
      {isLoading && !poster && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/20 backdrop-blur-sm">
          <div className="relative w-12 h-12">
            {/* Spinner */}
            <div className="absolute inset-0 border-4 border-white/20 rounded-full"></div>
            <div className="absolute inset-0 border-4 border-transparent border-t-white rounded-full animate-spin"></div>
          </div>
        </div>
      )}

      {/* Error State */}
      {hasError && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/50">
          <div className="text-white text-sm opacity-75">Video konnte nicht geladen werden</div>
        </div>
      )}
    </div>
  )
}
